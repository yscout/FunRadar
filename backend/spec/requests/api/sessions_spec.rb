require "rails_helper"

RSpec.describe "Api::Sessions", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  describe "POST /api/session" do
    it "returns an error when the name is blank" do
      post "/api/session", params: { name: "   " }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response.fetch("error")).to eq("param is missing or the value is empty or invalid: name")
    end

    it "creates a new user, claims invitations, and returns the full payload" do
      event = create(:event)
      invitation = create(:invitation, event:, invitee: nil, invitee_name: "Jamie Doe")

      freeze_time do
        expect {
          post "/api/session", params: { name: "  Jamie Doe  " }
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:ok)

        body = json_response
        expect(body.fetch("user")).to include("name" => "Jamie Doe")
        expect(body.fetch("invitations").first).to include(
          "id" => invitation.id,
          "event" => hash_including("id" => event.id),
          "access_token" => invitation.access_token
        )
        expect(body.fetch("organized_events")).to eq([])

        new_user = User.find(body.fetch("user").fetch("id"))
        expect(new_user.last_signed_in_at).to eq(Time.current)
        expect(invitation.reload.invitee_id).to eq(new_user.id)
      end
    end

    it "reuses an existing user case-insensitively and updates timestamps" do
      user = create(:user, name: "Taylor Swift", last_signed_in_at: 2.days.ago)
      organized_event = create(:event, organizer: user)
      create(:invitation, event: organized_event, invitee: user, role: :organizer)

      expect {
        post "/api/session", params: { name: "  taylor swift  " }
      }.not_to change(User, :count)

      expect(response).to have_http_status(:ok)

      body = json_response
      expect(body.fetch("user").fetch("id")).to eq(user.id)
      expect(body.fetch("organized_events").map { |event| event.fetch("id") })
        .to contain_exactly(organized_event.id)

      user.reload
      expect(user.last_signed_in_at).to be_within(1.second).of(Time.current)
    end
  end
end