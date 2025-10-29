require 'rails_helper'

RSpec.describe "Api::Preferences", type: :request do
  let(:event) { create(:event) }
  let(:invitation) { create(:invitation, event: event) }

  describe "GET /api/invitations/:token/preference" do
    context "when preference exists" do
      let!(:preference) { create(:preference, invitation: invitation) }

      it "returns preference details" do
        get "/api/invitations/#{invitation.access_token}/preference"
        
        expect(response).to have_http_status(:ok)
        expect(json_response).to include("invitation", "preference", "event")
        expect(json_response["preference"]["activities"]).to eq(preference.activities)
      end
    end

    context "when preference does not exist" do
      it "returns null preference" do
        get "/api/invitations/#{invitation.access_token}/preference"
        
        expect(response).to have_http_status(:ok)
        expect(json_response["preference"]).to be_nil
      end
    end

    context "with invalid token" do
      it "returns not found" do
        get "/api/invitations/invalid-token/preference"
        
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /api/invitations/:token/preference" do
    let(:valid_params) do
      {
        preference: {
          available_times: ["Saturday 3:00 PM", "Sunday 10:00 AM"],
          activities: ["Dinner", "Coffee"],
          budget_min: 15,
          budget_max: 60,
          ideas: "Something fun and casual"
        }
      }
    end

    context "with valid parameters" do
      it "creates a new preference" do
        expect {
          post "/api/invitations/#{invitation.access_token}/preference", params: valid_params
        }.to change(Preference, :count).by(1)
        
        expect(response).to have_http_status(:ok)
      end

      it "returns created preference" do
        post "/api/invitations/#{invitation.access_token}/preference", params: valid_params
        
        expect(json_response["preference"]["activities"]).to eq(["Dinner", "Coffee"])
        expect(json_response["preference"]["budget_min"]).to eq(15)
        expect(json_response["preference"]["budget_max"]).to eq(60)
      end

      it "marks invitation as submitted" do
        post "/api/invitations/#{invitation.access_token}/preference", params: valid_params
        
        expect(invitation.reload.status).to eq("submitted")
        expect(invitation.responded_at).to be_present
      end

      it "triggers AI processing when all preferences submitted" do
        event = create(:event, :with_invitations)
        last_invitation = event.invitations.participant.last
        
        # Submit all but last
        event.invitations.participant[0..-2].each do |inv|
          create(:preference, invitation: inv)
        end
        
        # Submit organizer preference
        organizer_invitation = event.invitations.organizer.first
        create(:preference, invitation: organizer_invitation)
        
        expect(GenerateActivitySuggestionsJob).to receive(:perform_later).with(event.id)
        
        post "/api/invitations/#{last_invitation.access_token}/preference", params: valid_params
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          preference: {
            available_times: [],
            activities: ["Dinner"],
            budget_min: 50,
            budget_max: 10  # Invalid: max < min
          }
        }
      end

      it "returns unprocessable entity" do
        post "/api/invitations/#{invitation.access_token}/preference", params: invalid_params
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response["errors"]).to be_present
      end
    end

    context "when preference already exists" do
      let!(:existing_preference) { create(:preference, invitation: invitation) }

      it "updates existing preference" do
        expect {
          post "/api/invitations/#{invitation.access_token}/preference", params: valid_params
        }.not_to change(Preference, :count)
        
        expect(existing_preference.reload.activities).to eq(["Dinner", "Coffee"])
      end
    end
  end

  describe "PATCH /api/invitations/:token/preference" do
    let!(:preference) { create(:preference, invitation: invitation) }
    let(:update_params) do
      {
        preference: {
          available_times: ["Friday 7:00 PM"],
          activities: ["Movies"],
          budget_min: 20,
          budget_max: 40,
          ideas: "Updated ideas"
        }
      }
    end

    it "updates the preference" do
      patch "/api/invitations/#{invitation.access_token}/preference", params: update_params
      
      expect(response).to have_http_status(:ok)
      expect(preference.reload.activities).to eq(["Movies"])
      expect(preference.budget_min).to eq(20)
    end

    it "returns updated preference" do
      patch "/api/invitations/#{invitation.access_token}/preference", params: update_params
      
      expect(json_response["preference"]["ideas"]).to eq("Updated ideas")
    end
  end
end

