module Ai
  class GroupMatchService
    SYSTEM_PROMPT = <<~PROMPT
      You are an assistant helping a group of friends choose an activity.
      Always respond with JSON containing a `matches` array.
      Each match must include:
      id (integer), title (string), compatibility (integer 0-100), image (string URL),
      location (string), price (string), time (string), emoji (string),
      votes (integer), description (string).
      Do not include any additional keys. Provide 3 to 5 matches.
      Focus on variety and align choices with the shared availability, activities, budgets, ideas, and locations.
      The location is not a strict constraint. The choices should NOT be only close to a few participants but very far from others.
    PROMPT

    FALLBACK_MATCHES = [
      {
        "id" => 1,
        "title" => "Free Jazz Picnic",
        "compatibility" => 95,
        "image" => "https://images.unsplash.com/photo-1603543900250-275a638755a9",
        "location" => "Central Park",
        "price" => "$15/person",
        "time" => "Saturday, 3:00 PM",
        "emoji" => "🎶",
        "votes" => 4,
        "description" => "Live jazz band with picnic setup and food trucks"
      },
      {
        "id" => 2,
        "title" => "Rooftop Dinner",
        "compatibility" => 88,
        "image" => "https://images.unsplash.com/photo-1742002661612-771125d0c050",
        "location" => "Downtown Skybar",
        "price" => "$45/person",
        "time" => "Friday, 7:00 PM",
        "emoji" => "🍽️",
        "votes" => 4,
        "description" => "Italian cuisine with city views"
      },
      {
        "id" => 3,
        "title" => "Coffee & Catch Up",
        "compatibility" => 85,
        "image" => "https://images.unsplash.com/photo-1721845706930-b3a05aa70baa",
        "location" => "The Brew House",
        "price" => "$8/person",
        "time" => "Sunday, 10:00 AM",
        "emoji" => "☕",
        "votes" => 4,
        "description" => "Cozy cafe with board games"
      }
    ].freeze

    def initialize(event, client: default_client)
      @event = event
      @client = client
    end

    def call
      return FALLBACK_MATCHES if preferences.blank?

      content = request_suggestions
      matches = parse_matches(content)
      matches.presence || FALLBACK_MATCHES
    rescue StandardError => error
      Rails.logger.error("Ai::GroupMatchService failure for event=#{@event.id}: #{error.class} #{error.message}")
      FALLBACK_MATCHES
    end

    private

    def preferences
      @preferences ||= @event.preferences.includes(:invitation)
    end

    def request_payload
      {
        event: {
            title: @event.title,
            notes: @event.notes,
            organizer: @event.organizer.name,
            location: @event.organizer.location_hash
        },
        attendees: preferences.map do |preference|
          {
            name: preference.invitation.display_name,
            available_times: preference.available_times,
            activities: preference.activities,
            budget_min: preference.budget_min,
            budget_max: preference.budget_max,
            ideas: preference.ideas,
            location: preference_location(preference)
        }.compact
        end,
        summary: aggregated_preferences
      }
    end

    def preference_location(preference)
      if preference.location_latitude && preference.location_longitude
        {
          latitude: preference.location_latitude.to_f,
          longitude: preference.location_longitude.to_f
        }
      else
        preference.invitation.invitee&.location_hash
      end
    end

    def aggregated_preferences
      all_times = preferences.flat_map(&:available_times)
      all_activities = preferences.flat_map(&:activities)
      mins = preferences.map(&:budget_min).compact
      maxes = preferences.map(&:budget_max).compact
      coords = preferences.filter_map { preference_location(_1) }

      {
        top_time_slots: tally(all_times),
        top_activities: tally(all_activities),
        budget_range: mins.any? && maxes.any? ? { min: mins.min, max: maxes.max } : nil,
        locations: coords.presence
      }.compact
    end

    def tally(values)
      values
        .map(&:to_s)
        .reject(&:blank?)
        .tally
        .sort_by { |_, count| -count }
        .map { |value, count| { value: value, votes: count } }
        .first(8)
    end

    def request_suggestions
      response = @client.chat(
        parameters: {
          model: "gpt-5-mini",
          messages: [
            { role: "system", content: SYSTEM_PROMPT },
            { role: "user", content: request_payload.to_json }
          ],
          response_format: { type: "json_object" }
        }
      )
      response.dig("choices", 0, "message", "content")
    end

    def parse_matches(content)
      return [] if content.blank?

      data = JSON.parse(content)
      data.fetch("matches", [])
    rescue JSON::ParserError
      []
    end

    def default_client
      access_token = ENV.fetch("OPENAI_KEY")
      OpenAI::Client.new(access_token: access_token)
    end
  end
end