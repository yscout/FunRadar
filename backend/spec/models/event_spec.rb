require 'rails_helper'

RSpec.describe Event, type: :model do
  include ActiveSupport::Testing::TimeHelpers
  describe 'associations' do
    it { should belong_to(:organizer).class_name('User') }
    it { should have_many(:invitations).dependent(:destroy) }
    it { should have_many(:preferences).through(:invitations) }
    it { should have_many(:activity_suggestions).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:event) }

    it { should validate_length_of(:title).is_at_most(120) }
    
    it 'validates uniqueness of share_token' do
      event1 = create(:event)
      event2 = build(:event, share_token: event1.share_token)
      expect(event2).not_to be_valid
      expect(event2.errors[:share_token]).to include('has already been taken')
    end
    
    it 'validates presence of title after callback' do
      event = Event.new(title: nil, organizer: create(:user))
      event.valid?
      expect(event.title).to eq('New Hangout')
    end
    
    it 'validates presence of share_token after callback' do
      event = Event.new(title: 'Test', organizer: create(:user), share_token: nil)
      event.valid?
      expect(event.share_token).to be_present
    end
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(collecting: 0, pending_ai: 1, ready: 2, completed: 3).with_default(:collecting) }
  end

  describe 'callbacks' do
    describe '#ensure_title' do
      it 'sets default title when blank' do
        event = create(:event, title: '')
        expect(event.title).to eq('New Hangout')
      end

      it 'keeps provided title' do
        event = create(:event, title: 'Party Time')
        expect(event.title).to eq('Party Time')
      end
    end

    describe '#ensure_share_token' do
      it 'generates share_token if not provided' do
        event = build(:event, share_token: nil)
        event.save
        expect(event.share_token).to be_present
        expect(event.share_token).to match(/^[a-f0-9\-]{36}$/)
      end

      it 'keeps provided share_token' do
        token = SecureRandom.uuid
        event = create(:event, share_token: token)
        expect(event.share_token).to eq(token)
      end
    end
  end

  describe '#progress_snapshot' do
    let(:event) { create(:event, :with_invitations) }

    it 'returns an array of invitation progress payloads' do
      snapshot = event.progress_snapshot
      expect(snapshot).to be_an(Array)
      expect(snapshot.length).to eq(4)
      expect(snapshot.first).to include(:id, :name, :role, :status)
    end

    it 'orders by creation time' do
      event = create(:event)
      first_invitation = create(:invitation, event: event, created_at: 1.day.ago)
      second_invitation = create(:invitation, event: event, created_at: 1.hour.ago)

      snapshot = event.progress_snapshot
      expect(snapshot.first[:id]).to eq(first_invitation.id)
      expect(snapshot.last[:id]).to eq(second_invitation.id)
    end
  end

  describe '#all_preferences_submitted?' do
    context 'when all participants have submitted preferences' do
      let(:event) { create(:event, :with_submitted_preferences) }

      it 'returns true' do
        expect(event.all_preferences_submitted?).to be true
      end
    end

    context 'when some participants have not submitted' do
      let(:event) { create(:event, :with_invitations) }

      it 'returns false' do
        expect(event.all_preferences_submitted?).to be false
      end
    end

    context 'when there are no participants' do
      let(:event) { create(:event) }

      it 'returns false' do
        expect(event.all_preferences_submitted?).to be false
      end
    end
  end

  describe '#enqueue_ai_if_ready!' do
    context 'when all preferences are submitted and status is collecting' do
      let(:event) do
        evt = create(:event, :with_submitted_preferences)
        # Reset status to collecting after preferences auto-triggered the callback
        evt.update_column(:status, Event.statuses[:collecting])
        evt
      end

      it 'updates status to pending_ai' do
        expect {
          event.enqueue_ai_if_ready!
        }.to change { event.reload.status }.from('collecting').to('pending_ai')
      end

      it 'enqueues the GenerateActivitySuggestionsJob' do
        expect(GenerateActivitySuggestionsJob).to receive(:perform_later).with(event.id)
        event.enqueue_ai_if_ready!
      end
    end

    context 'when not all preferences are submitted' do
      let(:event) { create(:event, :with_invitations) }

      it 'does not change status' do
        expect {
          event.enqueue_ai_if_ready!
        }.not_to change { event.status }
      end

      it 'does not enqueue job' do
        expect(GenerateActivitySuggestionsJob).not_to receive(:perform_later)
        event.enqueue_ai_if_ready!
      end
    end

    context 'when status is already pending_ai' do
      let(:event) { create(:event, :with_submitted_preferences, :pending_ai) }

      it 'does not enqueue job again' do
        expect(GenerateActivitySuggestionsJob).not_to receive(:perform_later)
        event.enqueue_ai_if_ready!
      end
    end

    context 'when status is ready' do
      let(:event) { create(:event, :with_submitted_preferences, :ready) }

      it 'does not enqueue job' do
        expect(GenerateActivitySuggestionsJob).not_to receive(:perform_later)
        event.enqueue_ai_if_ready!
      end
    end
  end

  describe '#latest_suggestions' do
    let(:event) { create(:event) }

    it 'returns the most recent activity suggestion' do
      old_suggestion = create(:activity_suggestion, event: event, created_at: 1.day.ago)
      new_suggestion = create(:activity_suggestion, event: event, created_at: 1.hour.ago)

      expect(event.latest_suggestions).to eq(new_suggestion)
    end
  end

  describe '#aggregate_preferences' do
    let(:event) { create(:event, :with_submitted_preferences) }

    it 'returns an array of preference API data' do
      preferences = event.aggregate_preferences
      expect(preferences).to be_an(Array)
      expect(preferences.length).to eq(4)
      expect(preferences.first).to include(:available_times, :activities, :budget_min, :budget_max, :ideas)
    end
  end

  describe '#current_match_ids' do
    let(:event) { create(:event) }

    context 'when there are activity suggestions' do
      it 'returns match IDs from latest suggestions' do
        suggestion = create(:activity_suggestion, event: event, payload: [
          { "id" => "match-1", "title" => "Activity 1" },
          { "id" => "match-2", "title" => "Activity 2" }
        ])

        expect(event.current_match_ids).to contain_exactly("match-1", "match-2")
      end

      it 'returns only IDs from the latest suggestion' do
        old_suggestion = create(:activity_suggestion, event: event, created_at: 1.day.ago, payload: [
          { "id" => "old-match", "title" => "Old Activity" }
        ])
        new_suggestion = create(:activity_suggestion, event: event, created_at: 1.hour.ago, payload: [
          { "id" => "new-match", "title" => "New Activity" }
        ])

        expect(event.current_match_ids).to contain_exactly("new-match")
      end
    end

    context 'when there are no activity suggestions' do
      it 'returns empty array' do
        expect(event.current_match_ids).to eq([])
      end
    end
  end

  describe '#voting_invitations' do
    let(:event) { create(:event) }

    it 'returns all invitations' do
      invitation1 = create(:invitation, event: event)
      invitation2 = create(:invitation, event: event)

      expect(event.voting_invitations).to contain_exactly(invitation1, invitation2)
    end
  end

  describe '#votes_summary' do
    let(:event) { create(:event, status: :ready) }
    let(:invitation1) { create(:invitation, event: event) }
    let(:invitation2) { create(:invitation, event: event) }

    before do
      create(:activity_suggestion, event: event, payload: [
        { "id" => "match-1", "title" => "Activity 1" },
        { "id" => "match-2", "title" => "Activity 2" }
      ])
    end

    it 'returns summary of votes for each match' do
      create(:match_vote, invitation: invitation1, event: event, match_id: "match-1", score: 5)
      create(:match_vote, invitation: invitation2, event: event, match_id: "match-1", score: 3)
      create(:match_vote, invitation: invitation1, event: event, match_id: "match-2", score: 4)

      summary = event.votes_summary

      expect(summary["match-1"]).to include(
        total_score: 8,
        ratings_count: 2
      )
      expect(summary["match-2"]).to include(
        total_score: 4,
        ratings_count: 1
      )
    end

    it 'returns empty summary for matches with no votes' do
      summary = event.votes_summary

      expect(summary["match-1"]).to include(
        total_score: 0,
        ratings_count: 0
      )
    end
  end

  describe '#finalize_if_ready!' do
    let(:event) { create(:event, status: :ready) }
    let(:organizer_invitation) { create(:invitation, event: event, role: :organizer, status: :submitted) }
    let(:invitation1) { create(:invitation, event: event, status: :submitted) }
    let(:invitation2) { create(:invitation, event: event, status: :submitted) }

    before do
      organizer_invitation
      invitation1
      invitation2
      create(:activity_suggestion, event: event, payload: [
        { "id" => "match-1", "title" => "Activity 1" },
        { "id" => "match-2", "title" => "Activity 2" }
      ])
    end

    context 'when event is not ready' do
      let(:event) { create(:event, status: :collecting) }

      it 'does not finalize' do
        expect {
          event.finalize_if_ready!
        }.not_to change { event.reload.status }
      end
    end

    context 'when event is already completed' do
      let(:event) { create(:event, status: :completed) }

      it 'does not finalize again' do
        expect {
          event.finalize_if_ready!
        }.not_to change { event.reload.status }
      end
    end

    context 'when there are no match IDs' do
      before do
        event.activity_suggestions.destroy_all
      end

      it 'does not finalize' do
        expect {
          event.finalize_if_ready!
        }.not_to change { event.reload.status }
      end
    end

    context 'when not everyone has voted' do
      before do
        create(:match_vote, invitation: invitation1, event: event, match_id: "match-1", score: 5)
        # invitation2 hasn't voted
      end

      it 'does not finalize' do
        expect {
          event.finalize_if_ready!
        }.not_to change { event.reload.status }
      end
    end

    context 'when not all invitations have submitted' do
      let(:invitation2) { create(:invitation, event: event, status: :pending) }

      before do
        create(:match_vote, invitation: invitation1, event: event, match_id: "match-1", score: 5)
        create(:match_vote, invitation: invitation2, event: event, match_id: "match-1", score: 3)
      end

      it 'does not finalize' do
        expect {
          event.finalize_if_ready!
        }.not_to change { event.reload.status }
      end
    end

    context 'when everyone has voted on all matches' do
      before do
        [organizer_invitation, invitation1, invitation2].each do |inv|
          create(:match_vote, invitation: inv, event: event, match_id: "match-1", score: 5)
          create(:match_vote, invitation: inv, event: event, match_id: "match-2", score: 3)
        end
        event.update_column(:status, Event.statuses[:ready]) if event.reload.completed?
      end

      it 'finalizes the event' do
        expect {
          event.finalize_if_ready!
        }.to change { event.reload.status }.from('ready').to('completed')
      end

      it 'sets the winning match' do
        event.update_column(:status, Event.statuses[:ready]) if event.reload.completed?
        
        event.finalize_if_ready!
        event.reload

        expect(event.final_match).to be_present
        expect(event.final_match["id"]).to eq("match-1")
      end

      it 'sets completed_at timestamp' do
        event.update_column(:status, Event.statuses[:ready]) if event.reload.completed?
        freeze_time do
          event.finalize_if_ready!
          event.reload

          expect(event.completed_at).to be_within(1.second).of(Time.current)
        end
      end

      context 'when winning match is not found in suggestions' do
        before do
          event.update_column(:status, Event.statuses[:ready]) if event.reload.completed?
        end

        it 'sets empty final_match when winning match ID is not found' do
          allow(event).to receive(:current_match_ids).and_return(["match-1"])
          allow(event).to receive(:latest_suggestions).and_return(
            double(matches: [{ "id" => "match-2", "title" => "Activity 2" }])
          )
          event.finalize_if_ready!
          event.reload

          expect(event.final_match).to eq({})
        end
      end
    end
  end

  describe '#to_api' do
    let(:organizer) { create(:user, name: 'Alice') }
    let(:event) { create(:event, :with_submitted_preferences, organizer: organizer) }

    it 'returns event data with all required fields' do
      api_data = event.to_api

      expect(api_data).to include(
        :id, :title, :notes, :status, :organizer, :share_token, 
        :created_at, :updated_at, :progress, :submitted_count, 
        :participant_count, :matches, :ai_generated_at
      )
    end

    it 'includes organizer information' do
      api_data = event.to_api
      expect(api_data[:organizer]).to include(id: organizer.id, name: organizer.name)
    end

    context 'with include_progress: false' do
      it 'excludes progress information' do
        api_data = event.to_api(include_progress: false)
        expect(api_data).not_to include(:progress, :submitted_count, :participant_count)
      end
    end

    context 'with include_results: false' do
      it 'excludes results information' do
        api_data = event.to_api(include_results: false)
        expect(api_data).not_to include(:matches, :ai_generated_at)
      end
    end

    context 'when event has final_match' do
      let(:event) { create(:event, status: :completed, final_match: { "id" => "match-1", "title" => "Winner" }) }

      it 'includes final_match in response' do
        api_data = event.to_api
        expect(api_data[:final_match]).to eq({ "id" => "match-1", "title" => "Winner" })
      end
    end

    context 'when event has completed_at' do
      let(:event) { create(:event, status: :completed, completed_at: Time.current) }

      it 'includes completed_at in response' do
        api_data = event.to_api
        expect(api_data[:completed_at]).to be_present
      end
    end

    context 'when preferences should be included' do
      it 'includes preferences when include_progress is true' do
        api_data = event.to_api(include_progress: true)
        expect(api_data[:preferences]).to be_present
      end

      it 'includes preferences when include_results is true' do
        api_data = event.to_api(include_results: true)
        expect(api_data[:preferences]).to be_present
      end

      it 'excludes preferences when both are false' do
        api_data = event.to_api(include_progress: false, include_results: false)
        expect(api_data).not_to have_key(:preferences)
      end
    end
  end
end

