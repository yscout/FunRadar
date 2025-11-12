require 'rails_helper'

RSpec.describe "Api::Invitations", type: :request do
  let(:event) { create(:event) }
  let(:invitation) { create(:invitation, event: event) }

  describe "GET /api/invitations" do
    let(:user) { create(:user) }
    let(:headers) { auth_headers(user) }

    context "when user is authenticated" do
      it "returns user's invitations" do
        invitation1 = create(:invitation, event: event, invitee: user)
        invitation2 = create(:invitation, event: create(:event), invitee: user)
        other_invitation = create(:invitation, event: event) # Not for this user

        get "/api/invitations", headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response["invitations"].length).to eq(2)
        invitation_ids = json_response["invitations"].map { |inv| inv["id"] }
        expect(invitation_ids).to contain_exactly(invitation1.id, invitation2.id)
      end

      it "includes access tokens in response" do
        invitation = create(:invitation, event: event, invitee: user)

        get "/api/invitations", headers: headers

        expect(json_response["invitations"].first["access_token"]).to eq(invitation.access_token)
      end

      it "includes event details in response" do
        invitation = create(:invitation, event: event, invitee: user)

        get "/api/invitations", headers: headers

        expect(json_response["invitations"].first).to have_key("event")
        expect(json_response["invitations"].first["event"]["id"]).to eq(event.id)
      end

      it "orders invitations by creation time (newest first)" do
        old_invitation = create(:invitation, event: event, invitee: user, created_at: 2.days.ago)
        new_invitation = create(:invitation, event: create(:event), invitee: user, created_at: 1.hour.ago)

        get "/api/invitations", headers: headers

        invitation_ids = json_response["invitations"].map { |inv| inv["id"] }
        expect(invitation_ids.first).to eq(new_invitation.id)
        expect(invitation_ids.last).to eq(old_invitation.id)
      end

      it "claims matching invitations before returning" do
        matching_invitation = create(:invitation, event: event, invitee: nil, invitee_name: user.name)

        get "/api/invitations", headers: headers

        expect(matching_invitation.reload.invitee).to eq(user)
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized" do
        get "/api/invitations"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /api/invitations/:token" do
    context "with valid token" do
      it "returns invitation and event details" do
        get "/api/invitations/#{invitation.access_token}"
        
        expect(response).to have_http_status(:ok)
        expect(json_response).to include("invitation", "event")
        expect(json_response["invitation"]["id"]).to eq(invitation.id)
        expect(json_response["invitation"]["access_token"]).to be_present
      end
    end

    context "with invalid token" do
      it "returns not found" do
        get "/api/invitations/invalid-token"
        
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "PATCH /api/invitations/:token" do
    let(:user) { create(:user) }
    let(:headers) { auth_headers(user) }
    let(:invitation) { create(:invitation, event: event, invitee: nil) }

    context "when user is authenticated" do
      it "attaches current user to invitation" do
        patch "/api/invitations/#{invitation.access_token}", headers: headers
        
        expect(response).to have_http_status(:ok)
        expect(invitation.reload.invitee).to eq(user)
        expect(invitation.invitee_name).to eq(user.name)
      end

      it "returns updated invitation" do
        patch "/api/invitations/#{invitation.access_token}", headers: headers
        
        expect(json_response["invitation"]["invitee_id"]).to eq(user.id)
      end

      context "when invitation already has invitee" do
        let(:other_user) { create(:user) }
        let(:invitation) { create(:invitation, event: event, invitee: other_user) }

        it "does not change invitee" do
          patch "/api/invitations/#{invitation.access_token}", headers: headers
          
          expect(invitation.reload.invitee).to eq(other_user)
        end
      end
    end

    context "when user is not authenticated" do
      it "still succeeds (invitation can be accessed without auth)" do
        patch "/api/invitations/#{invitation.access_token}"
        
        expect(response).to have_http_status(:ok)
      end
    end
  end
end

