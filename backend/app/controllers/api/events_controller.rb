module Api
  class EventsController < BaseController
    before_action :require_current_user!, except: [:show]
    before_action :set_event, only: [:show, :progress, :results]
    before_action :authorize_event!, only: [:show, :progress, :results]

    def index
      organized = current_user.organized_events.includes(:invitations)
      invited = current_user.invitations.includes(:event).map(&:event)
      render json: {
        events: (organized + invited).uniq.map do |event|
          include_results = event.ready? || event.completed?
          event_payload(event, include_results:)
        end
      }
    end

    def create
      Event.transaction do
        event = current_user.organized_events.create!(event_params.slice(:title, :notes))
        create_organizer_invitation!(event)
        create_participant_invitations!(event)

        render json: { event: event_payload(event) }, status: :created
      end
    end

    def show
      render json: { event: event_payload(@event) }
    end

    def progress
      render json: {
        event: event_payload(@event, include_results: false),
        progress: @event.progress_snapshot
      }
    end

    def results
      invitation = current_user && @event.invitations.find_by(invitee: current_user)
      render json: {
        event: event_payload(@event, include_progress: false),
        matches: @event.latest_suggestions&.matches || [],
        votes_summary: @event.votes_summary,
        user_votes: invitation ? invitation.match_votes.pluck(:match_id, :score).to_h : {}
      }
    end

    private

    def set_event
      @event = Event.find(params[:id])
    end

    def authorize_event!
      return if current_user&.organized_events&.exists?(id: @event.id)
      return if current_user&.invitations&.exists?(event_id: @event.id)

      token = params[:share_token]
      return if token.present? && @event.share_token == token

      render json: { error: "Forbidden" }, status: :forbidden
    end

    def event_params
      params.require(:event).permit(
        :title,
        :notes,
        organizer_preferences: [:budget_min, :budget_max, :ideas, available_times: [], activities: []],
        invites: [:name, :email],
        invited_friends: []
      )
    end

    def organizer_preferences
      event_params.fetch(:organizer_preferences, {})
    end

    def create_organizer_invitation!(event)
      invitation = event.invitations.create!(
        role: :organizer,
        invitee: current_user,
        invitee_name: current_user.name,
        status: :submitted,
        responded_at: Time.current
      )

      invitation.create_preference!(
        available_times: Array(organizer_preferences[:available_times]),
        activities: Array(organizer_preferences[:activities]),
        budget_min: organizer_preferences[:budget_min],
        budget_max: organizer_preferences[:budget_max],
        ideas: organizer_preferences[:ideas]
      )
    end

    def create_participant_invitations!(event)
      invite_list = Array(event_params[:invites]).map(&:to_h)
      invite_list += Array(event_params[:invited_friends]).map { |name| { "name" => name } }

      invite_list.each do |invite|
        next if invite["name"].to_s.strip.blank?

        event.invitations.create!(
          role: :participant,
          invitee_name: invite["name"].to_s.strip,
          invitee_email: invite["email"]
        )
      end
    end
  end
end