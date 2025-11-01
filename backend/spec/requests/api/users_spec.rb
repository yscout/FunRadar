require "rails_helper"

RSpec.describe "Api::Users", type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers(user) }
  let(:path) { "/api/users/#{user.id}" }

  describe "PATCH /api/users/:id" do
    context "when authenticated" do
      it "updates location details when permission is granted" do
        patch path,
              params: {
                user: {
                  location_permission: true,
                  location_latitude: 40.7128,
                  location_longitude: -74.0060
                }
              },
              headers: headers

        expect(response).to have_http_status(:ok)

        payload = json_response.fetch("user")
        location = payload.fetch("location")
        expect(payload["location_permission"]).to be(true)
        expect(location["latitude"].to_f).to eq(40.7128)
        expect(location["longitude"].to_f).to eq(-74.0060)

        user.reload
        expect(user.location_permission).to be(true)
        expect(user.location_latitude).to eq(40.7128)
        expect(user.location_longitude).to eq(-74.0060)
      end

      it "clears coordinates when permission is revoked" do
        user.update!(
          location_permission: true,
          location_latitude: 12.34,
          location_longitude: 56.78
        )

        patch path,
              params: {
                user: {
                  location_permission: false,
                  location_latitude: 90.0,
                  location_longitude: 135.0
                }
              },
              headers: headers

        expect(response).to have_http_status(:ok)

        payload = json_response.fetch("user")
        expect(payload).to include(
          "location_permission" => false,
          "location" => nil
        )

        user.reload
        expect(user.location_permission).to be(false)
        expect(user.location_latitude).to be_nil
        expect(user.location_longitude).to be_nil
      end

      it "returns validation errors when the update fails" do
        allow_any_instance_of(User).to receive(:update).and_return(false)
        allow_any_instance_of(User).to receive(:update) do |instance, *_args|
          instance.errors.add(:base, "Something went wrong")
          false
        end

        patch path, params: { user: { location_permission: true } }, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response.fetch("errors")).to eq(["Something went wrong"])
      end
    end

    context "when unauthenticated" do
      it "returns unauthorized" do
        patch path, params: { user: { location_permission: true } }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end