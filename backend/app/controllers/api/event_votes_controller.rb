module Api
  class EventVotesController < BaseController
    before_action :require_current_user!
    before_action :set_event
    before_action :authorize_event!

    def create
      invitation = @event.invitations.find_by(invitee: current_user)
      return render json: { error: "Invitation not found" }, status: :forbidden unless invitation
      return render json: { error: "Event is not ready for voting" }, status: :unprocessable_entity unless @event.ready? || @event.completed?

      votes = vote_params.fetch(:votes, [])
      MatchVote.transaction do
        votes.each do |vote|
          match_id = vote[:match_id].to_s
          score = vote[:score].to_i
          next if match_id.blank?

          record = invitation.match_votes.find_or_initialize_by(match_id:)
          record.event = @event
          record.score = score
          record.save!
        end
      end

      @event.reload
      render json: {
        event: event_payload(@event, include_progress: false),
        votes_summary: @event.votes_summary,
        user_votes: invitation.match_votes.pluck(:match_id, :score).to_h
      }
    end

    private

    def set_event
      @event = Event.find(params[:event_id])
    end

    def authorize_event!
      allowed = @event.organizer_id == current_user.id ||
                current_user.invitations.exists?(event_id: @event.id)
      render json: { error: "Forbidden" }, status: :forbidden unless allowed
    end

    def vote_params
      params.permit(votes: [:match_id, :score])
    end
  end
end