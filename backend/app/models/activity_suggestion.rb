class ActivitySuggestion < ApplicationRecord
  belongs_to :event

  attribute :payload, :json, default: []

  validates :payload, presence: true

  def matches
    payload
  end

  def to_api
    {
      created_at: created_at,
      model_name: model_name,
      matches: matches
    }
  end
end