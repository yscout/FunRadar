require 'rails_helper'

RSpec.describe Event, type: :model do
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
    it { should define_enum_for(:status).with_values(collecting: 0, pending_ai: 1, ready: 2).with_default(:collecting) }
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
  end
end

