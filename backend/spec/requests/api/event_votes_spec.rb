require 'rails_helper'

RSpec.describe "Api::EventVotes", type: :request do
  let(:user) { create(:user) }
  let(:organizer) { create(:user) }
  let(:event) { create(:event, organizer: organizer, status: :ready) }
  let!(:invitation) { create(:invitation, event: event, invitee: user) }
  let(:headers) { auth_headers(user) }

  before do
    create(:activity_suggestion, event: event, payload: [
      { "id" => "match-1", "title" => "Activity 1" },
      { "id" => "match-2", "title" => "Activity 2" }
    ])
  end

  describe "POST /api/events/:event_id/votes" do
    context "when user is authenticated" do
      context "with valid invitation" do
        context "when event is ready for voting" do
          it "creates votes successfully" do
            vote_params = {
              votes: [
                { match_id: "match-1", score: 5 },
                { match_id: "match-2", score: 3 }
              ]
            }

            expect {
              post "/api/events/#{event.id}/votes", params: vote_params, headers: headers
            }.to change { invitation.match_votes.count }.by(2)

            expect(response).to have_http_status(:ok)
            expect(json_response).to include("event", "votes_summary", "user_votes")
            expect(json_response["user_votes"]["match-1"]).to eq(5)
            expect(json_response["user_votes"]["match-2"]).to eq(3)
          end

          it "updates existing votes" do
            create(:match_vote, invitation: invitation, event: event, match_id: "match-1", score: 2)

            vote_params = {
              votes: [
                { match_id: "match-1", score: 5 }
              ]
            }

            expect {
              post "/api/events/#{event.id}/votes", params: vote_params, headers: headers
            }.not_to change { invitation.match_votes.count }

            expect(response).to have_http_status(:ok)
            expect(json_response["user_votes"]["match-1"]).to eq(5)
          end

          it "skips blank match_ids" do
            vote_params = {
              votes: [
                { match_id: "match-1", score: 5 },
                { match_id: "", score: 3 },
                { match_id: nil, score: 2 }
              ]
            }

            expect {
              post "/api/events/#{event.id}/votes", params: vote_params, headers: headers
            }.to change { invitation.match_votes.count }.by(1)

            expect(response).to have_http_status(:ok)
          end

          it "includes votes summary in response" do
            other_user = create(:user)
            other_invitation = create(:invitation, event: event, invitee: other_user)
            create(:match_vote, invitation: other_invitation, event: event, match_id: "match-1", score: 4)

            vote_params = {
              votes: [
                { match_id: "match-1", score: 5 }
              ]
            }

            post "/api/events/#{event.id}/votes", params: vote_params, headers: headers

            expect(response).to have_http_status(:ok)
            expect(json_response).to have_key("votes_summary")
            expect(json_response["votes_summary"]).to be_a(Hash)
            expect(json_response["votes_summary"]["match-1"]).to include(
              "total_score" => 9,
              "ratings_count" => 2
            )
          end
        end

        context "when event is completed" do
          let(:event) { create(:event, organizer: organizer, status: :completed) }
          let(:invitation) { create(:invitation, event: event, invitee: user) }

          before do
            invitation
            create(:activity_suggestion, event: event, payload: [
              { "id" => "match-1", "title" => "Activity 1" }
            ])
          end

          it "allows voting on completed events" do
            vote_params = {
              votes: [
                { match_id: "match-1", score: 5 }
              ]
            }

            post "/api/events/#{event.id}/votes", params: vote_params, headers: headers

            expect(response).to have_http_status(:ok)
          end
        end

        context "when event is not ready for voting" do
          let(:event) { create(:event, organizer: organizer, status: :collecting) }
          let(:invitation) { create(:invitation, event: event, invitee: user) }

          before do
            invitation
          end

          it "returns unprocessable entity" do
            vote_params = {
              votes: [
                { match_id: "match-1", score: 5 }
              ]
            }

            post "/api/events/#{event.id}/votes", params: vote_params, headers: headers

            expect(response).to have_http_status(:unprocessable_entity)
            expect(json_response["error"]).to eq("Event is not ready for voting")
          end
        end
      end

      context "when invitation not found but user has access" do
        let(:other_user) { create(:user) }
        let(:headers) { auth_headers(other_user) }
        
        before do
          event.update(organizer: other_user)
        end

        it "returns forbidden with invitation not found message" do
          vote_params = {
            votes: [
              { match_id: "match-1", score: 5 }
            ]
          }

          post "/api/events/#{event.id}/votes", params: vote_params, headers: headers

          expect(response).to have_http_status(:forbidden)
          expect(json_response["error"]).to eq("Invitation not found")
        end
      end

      context "when user is the organizer" do
        let(:organizer_invitation) { create(:invitation, event: event, invitee: organizer, role: :organizer) }
        let(:headers) { auth_headers(organizer) }

        before do
          organizer_invitation
        end

        it "allows organizer to vote" do
          vote_params = {
            votes: [
              { match_id: "match-1", score: 5 }
            ]
          }

          post "/api/events/#{event.id}/votes", params: vote_params, headers: headers

          expect(response).to have_http_status(:ok)
        end
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized" do
        vote_params = {
          votes: [
            { match_id: "match-1", score: 5 }
          ]
        }

        post "/api/events/#{event.id}/votes", params: vote_params

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when event does not exist" do
      it "returns not found" do
        vote_params = {
          votes: [
            { match_id: "match-1", score: 5 }
          ]
        }

        post "/api/events/99999/votes", params: vote_params, headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user has no access to event" do
      let(:other_event) { create(:event) }
      let(:other_user) { create(:user) }
      let(:headers) { auth_headers(other_user) }

      it "returns forbidden" do
        vote_params = {
          votes: [
            { match_id: "match-1", score: 5 }
          ]
        }

        post "/api/events/#{other_event.id}/votes", params: vote_params, headers: headers

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end

