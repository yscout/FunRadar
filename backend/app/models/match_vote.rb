class MatchVote < ApplicationRecord
  belongs_to :event
  belongs_to :invitation

  validates :match_id, presence: true
  validates :score, inclusion: { in: 1..5 }
  validates :invitation_id, uniqueness: { scope: :match_id }

  after_commit :recalculate_event_completion, on: %i[create update]

  private

  def recalculate_event_completion
    event.finalize_if_ready!
  end
end