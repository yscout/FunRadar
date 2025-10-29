require 'rails_helper'

RSpec.describe Invitation, type: :model do
  describe 'associations' do
    it { should belong_to(:event) }
    it { should belong_to(:invitee).class_name('User').optional }
    it { should have_one(:preference).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:invitation) }

    it { should validate_presence_of(:invitee_name) }
    
    it 'validates uniqueness of access_token' do
      invitation1 = create(:invitation)
      invitation2 = build(:invitation, access_token: invitation1.access_token)
      expect(invitation2).not_to be_valid
      expect(invitation2.errors[:access_token]).to include('has already been taken')
    end
    
    it 'validates presence of access_token after callback' do
      invitation = Invitation.new(event: create(:event), invitee_name: 'Test User', access_token: nil)
      invitation.valid?
      expect(invitation.access_token).to be_present
    end
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values(organizer: 0, participant: 1).with_default(:participant) }
    it { should define_enum_for(:status).with_values(pending: 0, submitted: 1).with_default(:pending) }
  end

  describe 'callbacks' do
    describe '#ensure_access_token' do
      it 'generates access_token if not provided' do
        invitation = build(:invitation, access_token: nil)
        invitation.save
        expect(invitation.access_token).to be_present
        expect(invitation.access_token).to match(/^[a-f0-9\-]{36}$/)
      end

      it 'keeps provided access_token' do
        token = SecureRandom.uuid
        invitation = create(:invitation, access_token: token)
        expect(invitation.access_token).to eq(token)
      end
    end

    describe '#normalize_invitee_name' do
      it 'strips whitespace from invitee_name' do
        invitation = create(:invitation, invitee_name: '  John Doe  ')
        expect(invitation.invitee_name).to eq('John Doe')
      end

      it 'squishes multiple spaces in invitee_name' do
        invitation = create(:invitation, invitee_name: 'John    Doe')
        expect(invitation.invitee_name).to eq('John Doe')
      end
    end
  end

  describe 'scopes' do
    describe '.for_user' do
      let(:user) { create(:user) }
      let(:event) { create(:event) }

      it 'returns invitations for the specified user' do
        invitation1 = create(:invitation, event: event, invitee: user)
        invitation2 = create(:invitation, event: event, invitee: nil)

        expect(Invitation.for_user(user)).to include(invitation1)
        expect(Invitation.for_user(user)).not_to include(invitation2)
      end
    end
  end

  describe '#display_name' do
    context 'when invitee exists' do
      let(:user) { create(:user, name: 'Alice') }
      let(:invitation) { create(:invitation, invitee: user, invitee_name: 'Different Name') }

      it 'returns the invitee user name' do
        expect(invitation.display_name).to eq('Alice')
      end
    end

    context 'when invitee does not exist' do
      let(:invitation) { create(:invitation, invitee: nil, invitee_name: 'Bob') }

      it 'returns the invitee_name' do
        expect(invitation.display_name).to eq('Bob')
      end
    end
  end

  describe '#mark_submitted!' do
    let(:event) { create(:event, :with_invitations) }
    let(:invitation) { event.invitations.participant.first }

    context 'when not previously submitted' do
      it 'updates status to submitted' do
        expect {
          invitation.mark_submitted!
        }.to change { invitation.status }.from('pending').to('submitted')
      end

      it 'sets responded_at timestamp' do
        expect {
          invitation.mark_submitted!
        }.to change { invitation.responded_at }.from(nil)
        
        expect(invitation.responded_at).to be_present
      end

      it 'calls enqueue_ai_if_ready! on the event' do
        expect(event).to receive(:enqueue_ai_if_ready!)
        invitation.mark_submitted!
      end
    end

    context 'when already submitted' do
      let(:original_time) { 1.hour.ago }
      let(:invitation) { create(:invitation, :submitted, responded_at: original_time) }

      it 'does not update responded_at' do
        expect {
          invitation.mark_submitted!
        }.not_to change { invitation.reload.responded_at }
      end
    end
  end

  describe '#progress_payload' do
    let(:user) { create(:user, name: 'Alice') }
    let(:invitation) { create(:invitation, :submitted, invitee: user) }

    it 'returns a hash with invitation progress information' do
      payload = invitation.progress_payload

      expect(payload).to include(
        id: invitation.id,
        name: invitation.display_name,
        role: invitation.role,
        status: invitation.status,
        responded_at: invitation.responded_at,
        invitee_id: invitation.invitee_id
      )
    end
  end

  describe '#to_api' do
    let(:user) { create(:user, name: 'Alice') }
    let(:invitation) { create(:invitation, :with_preference, invitee: user) }

    it 'returns invitation data as a hash' do
      api_data = invitation.to_api

      expect(api_data).to include(
        id: invitation.id,
        role: invitation.role,
        status: invitation.status,
        name: invitation.display_name,
        responded_at: invitation.responded_at,
        event_id: invitation.event_id
      )
    end

    it 'excludes access_token by default' do
      api_data = invitation.to_api
      expect(api_data).not_to have_key(:access_token)
    end

    context 'with include_token: true' do
      it 'includes access_token' do
        api_data = invitation.to_api(include_token: true)
        expect(api_data[:access_token]).to eq(invitation.access_token)
      end
    end

    it 'includes preference data if present' do
      api_data = invitation.to_api
      expect(api_data[:preference]).to be_present
      expect(api_data[:preference]).to include(:available_times, :activities, :budget_min, :budget_max)
    end
  end
end

