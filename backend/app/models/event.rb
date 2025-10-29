class Event < ApplicationRecord
  belongs_to :organizer, class_name: "User"
  has_many :invitations, dependent: :destroy
  has_many :preferences, through: :invitations
  has_many :activity_suggestions, dependent: :destroy

  enum :status, { collecting: 0, pending_ai: 1, ready: 2 }, default: :collecting

  validates :title, presence: true, length: { maximum: 120 }
  validates :share_token, presence: true, uniqueness: true

  before_validation :ensure_title
  before_validation :ensure_share_token

  def ensure_title
    self.title = title.presence || "New Hangout"
  end

  def ensure_share_token
    self.share_token ||= SecureRandom.uuid
  end

  def progress_snapshot
    invitations.order(created_at: :asc).map(&:progress_payload)
  end

  def all_preferences_submitted?
    invitations.participant.exists? && invitations.participant.all?(&:submitted?)
  end

  def enqueue_ai_if_ready!
    return unless all_preferences_submitted?
    return if pending_ai? || ready?

    update!(status: :pending_ai)
    GenerateActivitySuggestionsJob.perform_later(id)
  end

  def latest_suggestions
    activity_suggestions.order(created_at: :desc).first
  end

  def aggregate_preferences
    preferences.includes(:invitation).map(&:to_api)
  end

  def to_api(include_progress: true, include_results: true)
    payload = {
      id: id,
      title: title,
      notes: notes,
      status: status,
      organizer: {
        id: organizer.id,
        name: organizer.name
      },
      share_token: share_token,
      created_at: created_at,
      updated_at: updated_at
    }

    if include_progress
      payload[:progress] = progress_snapshot
      payload[:submitted_count] = invitations.submitted.count
      payload[:participant_count] = invitations.participant.count
    end

    if include_results
      suggestion = latest_suggestions
      payload[:matches] = suggestion&.payload || []
      payload[:ai_generated_at] = ai_generated_at
    end

    payload
  end
end