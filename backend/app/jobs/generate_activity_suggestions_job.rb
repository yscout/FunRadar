class GenerateActivitySuggestionsJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    event = Event.find_by(id: event_id)
    return unless event
    return if event.ready?

    matches = Ai::GroupMatchService.new(event).call
    return if matches.blank?

    ActiveRecord::Base.transaction do
      event.match_votes.destroy_all
      event.activity_suggestions.create!(payload: matches, model_name: "gpt-5-mini")
      event.update!(
        status: :ready,
        ai_generated_at: Time.current,
        ai_summary: { matches: matches },
        final_match: {},
        completed_at: nil
      )
    end
  rescue StandardError => error
    Rails.logger.error("GenerateActivitySuggestionsJob failed for event=#{event_id}: #{error.class} #{error.message}")
  end
end