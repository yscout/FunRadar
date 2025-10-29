module Api
  class PreferencesController < BaseController
    before_action :set_invitation

    def show
      preference = @invitation.preference
      render json: {
        invitation: invitation_payload(@invitation, include_token: true),
        preference: preference&.to_api,
        event: event_payload(@invitation.event)
      }
    end

    def create
      preference = @invitation.preference || @invitation.build_preference
      if preference.update(preference_params)
        render json: {
          invitation: invitation_payload(@invitation, include_token: true),
          preference: preference.to_api,
          event: event_payload(@invitation.event)
        }
      else
        render json: { errors: preference.errors.full_messages }, status: :unprocessable_entity
      end
    end

    alias update create

    private

    def set_invitation
      @invitation = Invitation.find_by!(access_token: params[:invitation_token] || params[:token])
    end

    def preference_params
      params.require(:preference).permit(
        :budget_min,
        :budget_max,
        :ideas,
        :location_latitude,
        :location_longitude,
        available_times: [],
        activities: []
      )
    end
  end
end