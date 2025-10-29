require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:organized_events).class_name('Event').with_foreign_key(:organizer_id).dependent(:destroy) }
    it { should have_many(:invitations).with_foreign_key(:invitee_id).dependent(:nullify) }
  end

  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(120) }
    it { should validate_uniqueness_of(:name).case_insensitive }
  end

  describe 'callbacks' do
    describe '#normalize_name' do
      it 'strips whitespace from name' do
        user = create(:user, name: '  John Doe  ')
        expect(user.name).to eq('John Doe')
      end

      it 'squishes multiple spaces in name' do
        user = create(:user, name: 'John    Doe')
        expect(user.name).to eq('John Doe')
      end
    end
  end

  describe '#claim_matching_invitations!' do
    let(:user) { create(:user, name: 'Alice') }
    let(:event) { create(:event) }

    context 'when invitations match the user name' do
      it 'claims invitations with matching name' do
        invitation = create(:invitation, event: event, invitee_name: 'Alice', invitee: nil)
        
        user.claim_matching_invitations!
        
        expect(invitation.reload.invitee).to eq(user)
      end

      it 'is case insensitive' do
        invitation = create(:invitation, event: event, invitee_name: 'alice', invitee: nil)
        
        user.claim_matching_invitations!
        
        expect(invitation.reload.invitee).to eq(user)
      end
    end

    context 'when invitations do not match' do
      it 'does not claim non-matching invitations' do
        invitation = create(:invitation, event: event, invitee_name: 'Bob', invitee: nil)
        
        user.claim_matching_invitations!
        
        expect(invitation.reload.invitee).to be_nil
      end

      it 'does not claim invitations that already have an invitee' do
        other_user = create(:user, name: 'Bob')
        invitation = create(:invitation, event: event, invitee_name: 'Alice', invitee: other_user)
        
        user.claim_matching_invitations!
        
        expect(invitation.reload.invitee).to eq(other_user)
      end
    end
  end

  describe '#location_hash' do
    context 'when location permission is granted and coordinates exist' do
      let(:user) { create(:user, :with_location) }

      it 'returns a hash with latitude and longitude' do
        expect(user.location_hash).to include(:latitude, :longitude)
        expect(user.location_hash[:latitude]).to eq(user.location_latitude)
        expect(user.location_hash[:longitude]).to eq(user.location_longitude)
      end
    end

    context 'when location permission is not granted' do
      let(:user) { create(:user, location_permission: false) }

      it 'returns nil' do
        expect(user.location_hash).to be_nil
      end
    end

    context 'when coordinates are missing' do
      let(:user) { create(:user, location_permission: true, location_latitude: nil, location_longitude: nil) }

      it 'returns nil' do
        expect(user.location_hash).to be_nil
      end
    end
  end

  describe '#to_api' do
    let(:user) { create(:user, :with_location) }

    it 'returns user data as a hash' do
      api_data = user.to_api

      expect(api_data).to include(
        id: user.id,
        name: user.name,
        location_permission: user.location_permission,
        location: user.location_hash
      )
    end

    context 'when user has no location' do
      let(:user) { create(:user) }

      it 'includes nil location' do
        expect(user.to_api[:location]).to be_nil
      end
    end
  end
end

