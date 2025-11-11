module Api
  class SessionsController < BaseController
    def create
      name = params.require(:name).to_s.strip
      raise ActionController::ParameterMissing, "name cannot be blank" if name.blank?

      user, created = find_or_create_user(name)
      user.update!(last_signed_in_at: Time.current)
      user.claim_matching_invitations!

      participating_events = user.invitations.includes(:event).map(&:event)
      organized_events = user.organized_events.includes(:invitations)

      render json: {
        user: user.to_api,
        first_time: created && user.organized_events.none? && user.invitations.none?,
        invitations: user.invitations.includes(:event).map { |inv| invitation_payload(inv, include_event: true, include_token: true) },
        organized_events: organized_events.map { |event| event_payload(event) },
        participating_events: participating_events.uniq.map { |event| event_payload(event) },
        events: (organized_events + participating_events).uniq.map { |event| event_payload(event) }
      }
    end

    private

    def find_or_create_user(name)
      user = User.where("lower(name) = ?", name.downcase).first
      created = false
      unless user
        user = User.create!(name: name)
        created = true
      end
      [user, created]
    end
  end
end