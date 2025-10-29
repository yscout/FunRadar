module Api
  class SessionsController < BaseController
    def create
      name = params.require(:name).to_s.strip
      raise ActionController::ParameterMissing, "name cannot be blank" if name.blank?

      user = find_or_create_user(name)
      user.update!(last_signed_in_at: Time.current)
      user.claim_matching_invitations!

      render json: {
        user: user.to_api,
        invitations: user.invitations.includes(:event).map { |inv| invitation_payload(inv, include_event: true, include_token: true) },
        organized_events: user.organized_events.includes(:invitations).map { |event| event_payload(event) }
      }
    end

    private

    def find_or_create_user(name)
      User.where("lower(name) = ?", name.downcase).first_or_create!(name: name)
    end
  end
end