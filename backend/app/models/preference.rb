class Preference < ApplicationRecord
  belongs_to :invitation

  attribute :available_times, :json, default: []
  attribute :activities, :json, default: []

  validates :available_times, presence: true
  validates :activities, presence: true
  validates :budget_min, presence: true
  validates :budget_max, presence: true
  validate :budget_range_is_valid

  before_validation :stamp_submission_time
  after_commit :mark_invitation!, on: %i[create update]

  def stamp_submission_time
    self.submitted_at ||= Time.current
    self.available_times = Array(available_times).map(&:to_s)
    self.activities = Array(activities).map(&:to_s)
  end

  def budget_range_is_valid
    return if budget_min.blank? || budget_max.blank?
    errors.add(:budget_max, "must be greater than or equal to budget_min") if budget_max < budget_min
  end

  def mark_invitation!
    invitation.mark_submitted!
  end

  def to_api
    {
      name: invitation&.display_name,
      role: invitation&.role,
      invitee_id: invitation&.invitee_id,
      available_times: available_times,
      activities: activities,
      budget_min: budget_min,
      budget_max: budget_max,
      ideas: ideas,
      submitted_at: submitted_at
    }
  end
end