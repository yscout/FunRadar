class Invitation < ApplicationRecord
  belongs_to :event
  belongs_to :invitee, class_name: "User", optional: true
  has_one :preference, dependent: :destroy
  has_many :match_votes, dependent: :destroy

  enum :role, { organizer: 0, participant: 1 }, default: :participant
  enum :status, { pending: 0, submitted: 1 }, default: :pending

  validates :invitee_name, presence: true
  validates :access_token, presence: true, uniqueness: true

  before_validation :ensure_access_token
  before_validation :normalize_invitee_name

  scope :for_user, ->(user) { where(invitee: user) }

  def ensure_access_token
    self.access_token ||= SecureRandom.uuid
  end

  def normalize_invitee_name
    self.invitee_name = invitee_name.to_s.strip.squish if invitee_name.present?
  end

  def display_name
    invitee&.name || invitee_name
  end

  def mark_submitted!
    already_marked = submitted? && responded_at.present?
    update!(status: :submitted, responded_at: Time.current) unless already_marked
    event.enqueue_ai_if_ready!
  end

  def progress_payload
    {
      id: id,
      name: display_name,
      role: role,
      status: status,
      responded_at: responded_at,
      invitee_id: invitee_id
    }
  end

  def to_api(include_token: false)
    data = {
      id: id,
      role: role,
      status: status,
      name: display_name,
      responded_at: responded_at,
      event_id: event_id,
      invitee_id: invitee_id
    }
    data[:access_token] = access_token if include_token
    data[:preference] = preference&.to_api
    data
  end
end