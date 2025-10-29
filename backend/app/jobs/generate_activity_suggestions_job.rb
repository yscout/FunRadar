class GenerateActivitySuggestionsJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    event = Event.find_by(id: event_id)
    return unless event
    return if event.ready?

    matches = Ai::GroupMatchService.new(event).call
    return if matches.blank?

    ActiveRecord::Base.transaction do
      event.activity_suggestions.create!(payload: matches, model_name: "gpt-4.1")
      event.update!(status: :ready, ai_generated_at: Time.current, ai_summary: { matches: matches })
    end
  rescue StandardError => error
    Rails.logger.error("GenerateActivitySuggestionsJob failed for event=#{event_id}: #{error.class} #{error.message}")
  end
end