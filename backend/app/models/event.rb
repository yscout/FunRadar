class Event < ApplicationRecord
  belongs_to :organizer, class_name: "User"
  has_many :invitations, dependent: :destroy
  has_many :preferences, through: :invitations
  has_many :activity_suggestions, dependent: :destroy
  has_many :match_votes, dependent: :destroy

  enum :status, { collecting: 0, pending_ai: 1, ready: 2, completed: 3 }, default: :collecting

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

  def current_match_ids
    latest_suggestions&.matches&.map { |match| match["id"].to_s } || []
  end

  def voting_invitations
    invitations
  end

  def votes_summary
    current_match_ids.each_with_object({}) do |match_id, acc|
      scoped = match_votes.where(match_id:)
      acc[match_id] = {
        total_score: scoped.sum(:score),
        ratings_count: scoped.count
      }
    end
  end

  def finalize_if_ready!
    return unless ready?
    return if completed?

    match_ids = current_match_ids
    return if match_ids.blank?

    everyone_voted = voting_invitations.all? do |invitation|
      invitation.submitted? && match_ids.all? { |match_id| invitation.match_votes.exists?(match_id:) }
    end
    return unless everyone_voted

    winning_id, _score = match_ids.map { |match_id| [match_id, match_votes.where(match_id:).sum(:score)] }
                                  .max_by { |_, score| score }
    winning_match = latest_suggestions&.matches&.find { |match| match["id"].to_s == winning_id.to_s }

    update!(
      status: :completed,
      final_match: winning_match || {},
      completed_at: Time.current
    )
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
      payload[:participant_count] = invitations.participant.count + 1
    end

    if include_results
      suggestion = latest_suggestions
      payload[:matches] = suggestion&.payload || []
      payload[:ai_generated_at] = ai_generated_at
      payload[:votes_summary] = votes_summary
    end

    payload[:final_match] = final_match if final_match.present?
    payload[:completed_at] = completed_at
    payload[:preferences] = aggregate_preferences if include_progress || include_results

    payload
  end
end