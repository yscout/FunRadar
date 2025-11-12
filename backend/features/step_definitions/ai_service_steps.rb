Given('the AI client returns a valid JSON response') do
  content = {
    matches: [
      {
        id: 42,
        title: "Downtown Dinner",
        compatibility: 92,
        image: "https://example.com/dinner.jpg",
        location: "Downtown",
        price: "$45/person",
        time: "Friday 7:00 PM",
        emoji: "🍽️",
        votes: 0,
        description: "Private room with prix fixe menu"
      }
    ]
  }.to_json

  stub_response = {
    "choices" => [
      { "message" => { "content" => content } }
    ]
  }

  stub_client = double("OpenAI::Client", chat: stub_response)
  allow_any_instance_of(Ai::GroupMatchService).to receive(:default_client).and_return(stub_client)
end

Given('the AI client returns an invalid JSON response') do
  stub_response = {
    "choices" => [
      { "message" => { "content" => "not-valid-json" } }
    ]
  }
  stub_client = double("OpenAI::Client", chat: stub_response)
  allow_any_instance_of(Ai::GroupMatchService).to receive(:default_client).and_return(stub_client)
end

When('I run the AI group match service') do
  raise "Event must be defined" unless @event
  @ai_matches = Ai::GroupMatchService.new(@event).call
end

Then('the AI service should return structured matches') do
  expect(@ai_matches).to be_an(Array)
  expect(@ai_matches.first).to include("title", "compatibility", "description")
end

Then('the AI service should fall back to default matches') do
  expect(@ai_matches).to eq(Ai::GroupMatchService::FALLBACK_MATCHES)
end

Given('user {string} has location coordinates:') do |name, table|
  coords = table.rows_hash
  user = User.find_or_create_by!(name: name)
  user.update!(
    location_permission: true,
    location_latitude: coords['latitude'].to_f,
    location_longitude: coords['longitude'].to_f
  )
  invitation = @event.invitations.find_by(invitee_name: name) ||
               create(:invitation, event: @event, invitee_name: name)
  invitation.update!(invitee: user)
end

Given('no preferences have been submitted for the event') do
  @event.preferences.destroy_all
  @event.invitations.destroy_all
end
