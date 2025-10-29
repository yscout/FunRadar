require 'rails_helper'

RSpec.describe "Api::Events", type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers(user) }

  describe "GET /api/events" do
    context "when user is authenticated" do
      it "returns organized and invited events" do
        organized_event = create(:event, organizer: user)
        invited_event = create(:event)
        create(:invitation, event: invited_event, invitee: user)
        
        get "/api/events", headers: headers
        
        expect(response).to have_http_status(:ok)
        expect(json_response["events"].length).to eq(2)
      end

      it "does not include events user is not part of" do
        other_event = create(:event)
        
        get "/api/events", headers: headers
        
        expect(json_response["events"]).to be_empty
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized" do
        get "/api/events"
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST /api/events" do
    let(:valid_params) do
      {
        event: {
          title: "Weekend Hangout",
          notes: "Let's have fun!",
          organizer_preferences: {
            available_times: ["Saturday 3:00 PM", "Sunday 10:00 AM"],
            activities: ["Dinner", "Coffee"],
            budget_min: 10,
            budget_max: 50,
            ideas: "Something casual"
          },
          invited_friends: ["Alice", "Bob", "Charlie"]
        }
      }
    end

    context "when user is authenticated" do
      it "creates a new event" do
        expect {
          post "/api/events", params: valid_params, headers: headers
        }.to change(Event, :count).by(1)
        
        expect(response).to have_http_status(:created)
        expect(json_response["event"]["title"]).to eq("Weekend Hangout")
      end

      it "creates organizer invitation" do
        expect {
          post "/api/events", params: valid_params, headers: headers
        }.to change { Invitation.organizer.count }.by(1)
        
        event = Event.last
        organizer_invitation = event.invitations.organizer.first
        expect(organizer_invitation.invitee).to eq(user)
        expect(organizer_invitation.status).to eq("submitted")
      end

      it "creates organizer preference" do
        expect {
          post "/api/events", params: valid_params, headers: headers
        }.to change(Preference, :count).by(1)
        
        event = Event.last
        preference = event.invitations.organizer.first.preference
        expect(preference.activities).to eq(["Dinner", "Coffee"])
        expect(preference.budget_min).to eq(10)
        expect(preference.budget_max).to eq(50)
      end

      it "creates participant invitations" do
        expect {
          post "/api/events", params: valid_params, headers: headers
        }.to change { Invitation.participant.count }.by(3)
        
        event = Event.last
        participant_names = event.invitations.participant.map(&:invitee_name)
        expect(participant_names).to contain_exactly("Alice", "Bob", "Charlie")
      end

      it "handles empty invited_friends list" do
        params = valid_params.deep_dup
        params[:event][:invited_friends] = []
        
        post "/api/events", params: params, headers: headers
        
        expect(response).to have_http_status(:created)
        event = Event.last
        expect(event.invitations.participant.count).to eq(0)
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized" do
        post "/api/events", params: valid_params
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /api/events/:id" do
    let(:event) { create(:event, organizer: user) }

    context "when user is the organizer" do
      it "returns event details" do
        get "/api/events/#{event.id}", headers: headers
        
        expect(response).to have_http_status(:ok)
        expect(json_response["event"]["id"]).to eq(event.id)
      end
    end

    context "when user is invited" do
      let(:other_user) { create(:user) }
      let(:event) { create(:event, organizer: other_user) }

      before do
        create(:invitation, event: event, invitee: user)
      end

      it "returns event details" do
        get "/api/events/#{event.id}", headers: headers
        
        expect(response).to have_http_status(:ok)
        expect(json_response["event"]["id"]).to eq(event.id)
      end
    end

    context "when using share_token" do
      let(:other_user) { create(:user) }
      let(:event) { create(:event, organizer: other_user) }

      it "returns event details with valid share_token" do
        get "/api/events/#{event.id}?share_token=#{event.share_token}"
        
        expect(response).to have_http_status(:ok)
      end

      it "returns forbidden with invalid share_token" do
        get "/api/events/#{event.id}?share_token=invalid"
        
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when user has no access" do
      let(:other_event) { create(:event) }

      it "returns forbidden" do
        get "/api/events/#{other_event.id}", headers: headers
        
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when event does not exist" do
      it "returns not found" do
        get "/api/events/99999", headers: headers
        
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET /api/events/:id/progress" do
    let(:event) { create(:event, :with_invitations, organizer: user) }

    it "returns event progress" do
      get "/api/events/#{event.id}/progress", headers: headers
      
      expect(response).to have_http_status(:ok)
      expect(json_response).to include("event", "progress")
      expect(json_response["progress"]).to be_an(Array)
    end

    it "does not include results" do
      get "/api/events/#{event.id}/progress", headers: headers
      
      expect(json_response["event"]).not_to have_key("matches")
    end
  end

  describe "GET /api/events/:id/results" do
    let(:event) { create(:event, :ready, organizer: user) }

    before do
      create(:activity_suggestion, event: event)
    end

    it "returns event results" do
      get "/api/events/#{event.id}/results", headers: headers
      
      expect(response).to have_http_status(:ok)
      expect(json_response).to include("event", "matches")
      expect(json_response["matches"]).to be_an(Array)
    end

    it "does not include progress" do
      get "/api/events/#{event.id}/results", headers: headers
      
      expect(json_response["event"]).not_to have_key("progress")
    end
  end
end

