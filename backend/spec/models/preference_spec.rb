require 'rails_helper'

RSpec.describe Preference, type: :model do
  describe 'associations' do
    it { should belong_to(:invitation) }
  end

  describe 'validations' do
    subject { build(:preference) }

    it { should validate_presence_of(:available_times) }
    it { should validate_presence_of(:activities) }
    it { should validate_presence_of(:budget_min) }
    it { should validate_presence_of(:budget_max) }

    describe '#budget_range_is_valid' do
      it 'is valid when budget_max >= budget_min' do
        preference = build(:preference, budget_min: 10, budget_max: 50)
        expect(preference).to be_valid
      end

      it 'is invalid when budget_max < budget_min' do
        preference = build(:preference, budget_min: 50, budget_max: 10)
        expect(preference).not_to be_valid
        expect(preference.errors[:budget_max]).to include('must be greater than or equal to budget_min')
      end

      it 'is valid when budget_min equals budget_max' do
        preference = build(:preference, budget_min: 25, budget_max: 25)
        expect(preference).to be_valid
      end
    end
  end

  describe 'callbacks' do
    describe '#stamp_submission_time' do
      it 'sets submitted_at on create' do
        preference = build(:preference, submitted_at: nil)
        preference.save
        expect(preference.submitted_at).to be_present
      end

      it 'converts available_times to array of strings' do
        preference = create(:preference, available_times: ['Monday 6pm', 'Tuesday 7pm'])
        expect(preference.available_times).to all(be_a(String))
      end

      it 'converts activities to array of strings' do
        preference = create(:preference, activities: ['Dinner', 'Coffee'])
        expect(preference.activities).to all(be_a(String))
      end

      it 'handles empty arrays' do
        preference = build(:preference, available_times: [], activities: [])
        preference.save
        expect(preference.available_times).to eq([])
        expect(preference.activities).to eq([])
      end
    end

    describe '#mark_invitation!' do
      let(:event) { create(:event, :with_invitations) }
      let(:invitation) { event.invitations.participant.first }

      it 'calls mark_submitted! on the invitation' do
        preference = build(:preference, invitation: invitation)
        expect(invitation).to receive(:mark_submitted!)
        preference.save
      end
    end
  end

  describe '#to_api' do
    let(:preference) { create(:preference) }

    it 'returns preference data as a hash' do
      api_data = preference.to_api

      expect(api_data).to include(
        available_times: preference.available_times,
        activities: preference.activities,
        budget_min: preference.budget_min,
        budget_max: preference.budget_max,
        ideas: preference.ideas,
        submitted_at: preference.submitted_at
      )
    end

    it 'includes all available times' do
      preference = create(:preference, available_times: ['Monday 6pm', 'Tuesday 7pm', 'Wednesday 8pm'])
      api_data = preference.to_api
      expect(api_data[:available_times].length).to eq(3)
    end

    it 'includes all activities' do
      preference = create(:preference, activities: ['Dinner', 'Coffee', 'Movies'])
      api_data = preference.to_api
      expect(api_data[:activities].length).to eq(3)
    end
  end

  describe 'attribute defaults' do
    it 'defaults available_times to empty array' do
      preference = Preference.new
      expect(preference.available_times).to eq([])
    end

    it 'defaults activities to empty array' do
      preference = Preference.new
      expect(preference.activities).to eq([])
    end
  end

  describe 'budget scenarios' do
    context 'low budget preference' do
      let(:preference) { create(:preference, :low_budget) }

      it 'has budget range 5-20' do
        expect(preference.budget_min).to eq(5)
        expect(preference.budget_max).to eq(20)
      end
    end

    context 'high budget preference' do
      let(:preference) { create(:preference, :high_budget) }

      it 'has budget range 50-150' do
        expect(preference.budget_min).to eq(50)
        expect(preference.budget_max).to eq(150)
      end
    end
  end
end

