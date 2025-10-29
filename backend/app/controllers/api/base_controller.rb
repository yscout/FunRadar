module Api
  class BaseController < ApplicationController
    protect_from_forgery with: :null_session
    skip_before_action :verify_authenticity_token

    before_action :set_default_format

    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActionController::ParameterMissing, with: :render_unprocessable_entity

    private

    def set_default_format
      request.format = :json
    end

    def render_not_found
      render json: { error: "Not Found" }, status: :not_found
    end

    def render_unprocessable_entity(error)
      render json: { error: error.message }, status: :unprocessable_entity
    end

    def current_user
      return @current_user if defined?(@current_user)

      user_id = request.headers["X-User-Id"]
      @current_user = user_id.present? ? User.find_by(id: user_id) : nil
    end

    def require_current_user!
      return if current_user

      render json: { error: "Unauthorized" }, status: :unauthorized
    end

    def event_payload(event, include_progress: true, include_results: true)
      event.to_api(include_progress:, include_results:)
    end

    def invitation_payload(invitation, include_event: false, include_token: false)
      payload = invitation.to_api(include_token:)
      payload[:event] = event_payload(invitation.event) if include_event
      payload
    end
  end
end
