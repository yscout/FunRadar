module Api
  class InvitationsController < BaseController
    before_action :require_current_user!, only: [:index]
    before_action :set_invitation, only: [:show, :update]
    before_action :attach_current_user!, only: [:update]

    def index
      current_user.claim_matching_invitations!
      invitations = current_user.invitations.includes(:event).order(created_at: :desc)
      render json: {
        invitations: invitations.map { |inv| invitation_payload(inv, include_event: true, include_token: true) }
      }
    end

    def show
      render json: {
        invitation: invitation_payload(@invitation, include_event: true, include_token: true),
        event: event_payload(@invitation.event)
      }
    end

    def update
      if @invitation.save
        render json: {
          invitation: invitation_payload(@invitation, include_event: true, include_token: true),
          event: event_payload(@invitation.event)
        }
      else
        render json: { errors: @invitation.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def set_invitation
      @invitation = Invitation.find_by!(access_token: params[:token])
    end

    def attach_current_user!
      return unless current_user
      return if @invitation.invitee_id.present?

      @invitation.invitee = current_user
      @invitation.invitee_name = current_user.name
    end
  end
end