# http request helpers
def json_post(path, body)
  headers = {'CONTENT_TYPE' => 'application/json'}
  headers['HTTP_X_USER_ID'] = @current_user.id.to_s if @current_user
  
  post path, body.to_json, headers
  @last_response_status = last_response.status
  @last_response_body = last_response.body
  @last_response_json = JSON.parse(@last_response_body) rescue {}
end

def json_get(path)
  headers = {}
  headers['HTTP_X_USER_ID'] = @current_user.id.to_s if @current_user
  
  get path, {}, headers
  @last_response_status = last_response.status
  @last_response_body = last_response.body
  @last_response_json = JSON.parse(@last_response_body) rescue {}
end

def json_patch(path, body)
  headers = {'CONTENT_TYPE' => 'application/json'}
  headers['HTTP_X_USER_ID'] = @current_user.id.to_s if @current_user
  
  patch path, body.to_json, headers
  @last_response_status = last_response.status
  @last_response_body = last_response.body
  @last_response_json = JSON.parse(@last_response_body) rescue {}
end

Given('the database is clean') do
end

Given('I have a session as {string}') do |name|
  @current_user = User.find_or_create_by!(name: name)
end

# HTTP request steps
When('I POST to {string} with JSON:') do |path, json_string|
  path = path.gsub(':event_id', @created_event.id.to_s) if @created_event
  path = path.gsub(':user_id', @current_user.id.to_s) if @current_user
  
  body = JSON.parse(json_string)
  json_post path, body
  
  # capture created event if this was an event creation
  if path == '/api/events' && @last_response_status == 201 && @last_response_json.dig('event', 'id')
    @created_event = Event.find(@last_response_json['event']['id'])
  end
end

When('I GET {string}') do |path|
  path = path.gsub(':event_id', @created_event.id.to_s) if @created_event
  path = path.gsub(':user_id', @current_user.id.to_s) if @current_user
  
  json_get path
end

When('I PATCH {string} with JSON:') do |path, json_string|
  path = path.gsub(':event_id', @created_event.id.to_s) if @created_event
  path = path.gsub(':user_id', @current_user.id.to_s) if @current_user
  
  body = JSON.parse(json_string)
  json_patch path, body
end

# Response assertions
Then('the response status should be {int}') do |status_code|
  expect(@last_response_status).to eq(status_code)
end

Then('the JSON response should have {string}') do |json_path|
  keys = json_path.split('.')
  value = @last_response_json
  
  keys.each do |key|
    expect(value).to have_key(key), "Expected JSON to have key '#{key}' in path '#{json_path}'"
    value = value[key]
  end
end

Then('the JSON response should have {string} with value {string}') do |json_path, expected_value|
  keys = json_path.split('.')
  value = @last_response_json
  
  keys.each do |key|
    value = value[key]
  end
  
  expect(value.to_s).to eq(expected_value)
end

Then('the JSON response should have {string} with value {int}') do |json_path, expected_value|
  keys = json_path.split('.')
  value = @last_response_json
  
  keys.each do |key|
    value = value[key]
  end
  
  expect(value).to eq(expected_value)
end

Then('the JSON response should have {string} as an array') do |json_path|
  keys = json_path.split('.')
  value = @last_response_json
  
  keys.each do |key|
    value = value[key]
  end
  
  expect(value).to be_an(Array)
end

Then('the {string} array should have {int} items') do |json_path, count|
  keys = json_path.split('.')
  value = @last_response_json
  
  keys.each do |key|
    value = value[key]
  end
  
  expect(value.length).to eq(count)
end

Then('the {string} array should have at least {int} items') do |json_path, count|
  keys = json_path.split('.')
  value = @last_response_json
  
  keys.each do |key|
    value = value[key]
  end
  
  expect(value.length).to be >= count
end

# Database assertions
Then('a user {string} should exist in the database') do |name|
  user = User.find_by(name: name)
  expect(user).to be_present
end

Then('an event {string} should exist in the database') do |title|
  event = Event.find_by(title: title)
  expect(event).to be_present
  @created_event = event
end

Then('the event should have {int} participant invitations') do |count|
  expect(@created_event.invitations.participant.count).to eq(count)
end

Then('the invitation status should be {string}') do |status|
  invitation = Invitation.find_by(access_token: @invitation_token)
  expect(invitation.status).to eq(status)
end

Then('the preference should be updated') do
  invitation = Invitation.find_by(access_token: @invitation_token)
  expect(invitation.preference).to be_present
end

Then('the invitation should be attached to user {string}') do |name|
  user = User.find_by(name: name)
  invitation = Invitation.find_by(access_token: @invitation_token) || @test_invitation
  expect(invitation.invitee).to eq(user)
end

Then('the user location should be saved') do
  @current_user.reload
  expect(@current_user.location_latitude).to be_present
  expect(@current_user.location_longitude).to be_present
end

# Setup steps for scenarios
Given('I have created {int} events') do |count|
  count.times do |i|
    event = create(:event, title: "Event #{i+1}", organizer: @current_user)
    org_inv = create(:invitation, event: event, invitee: @current_user, role: :organizer, status: :submitted)
    create(:preference, invitation: org_inv)
  end
end

Given('{string} has been invited to {int} events') do |name, count|
  user = User.find_by(name: name) || @current_user
  count.times do |i|
    organizer = create(:user, name: "Organizer#{i+1}")
    event = create(:event, title: "Invite Event #{i+1}", organizer: organizer)
    create(:invitation, event: event, invitee: user, invitee_name: user.name, role: :participant)
  end
end

Given('I have an event {string}') do |title|
  @created_event = create(:event, title: title, organizer: @current_user)
  org_inv = create(:invitation, event: @created_event, invitee: @current_user, role: :organizer, status: :submitted)
  create(:preference, invitation: org_inv)
end

Given('{string} is invited with token {string}') do |name, token|
  unless @event
    organizer = @current_user || User.find_or_create_by!(name: 'TestOrganizer')
    @event = create(:event, organizer: organizer)
    org_inv = create(:invitation, event: @event, invitee: organizer, role: :organizer, status: :submitted)
    create(:preference, invitation: org_inv)
  end
  
  user = User.find_or_create_by(name: name)
  @invitation_token = token
  @test_invitation = create(:invitation, 
    event: @event, 
    invitee_name: name,
    access_token: token,
    role: :participant
  )
end

Given('{string} is invited with token {string} and has submitted preferences') do |name, token|
  unless @event
    organizer = @current_user || User.find_or_create_by!(name: 'TestOrganizer')
    @event = create(:event, organizer: organizer)
    org_inv = create(:invitation, event: @event, invitee: organizer, role: :organizer, status: :submitted)
    create(:preference, invitation: org_inv)
  end
  
  user = User.find_or_create_by(name: name)
  @invitation_token = token
  invitation = create(:invitation,
    event: @event,
    invitee_name: name,
    access_token: token,
    role: :participant,
    status: :submitted
  )
  create(:preference, invitation: invitation)
end

Given('I have an event {string} with {int} participants') do |title, count|
  @created_event = create(:event, title: title, organizer: @current_user)
  create(:invitation, event: @created_event, invitee: @current_user, role: :organizer, status: :submitted)
  create(:preference, invitation: @created_event.invitations.organizer.first)
  
  count.times do |i|
    create(:invitation, event: @created_event, invitee_name: "Participant #{i+1}", role: :participant)
  end
end

Given('for this event {int} participants have submitted preferences') do |count|
  @created_event.invitations.participant.first(count).each do |invitation|
    invitation.update(status: :submitted)
    create(:preference, invitation: invitation)
  end
end

Given('I have an event {string} with completed preferences') do |title|
  @created_event = create(:event, title: title, organizer: @current_user, status: :ready)
  
  organizer_inv = create(:invitation, event: @created_event, invitee: @current_user, role: :organizer, status: :submitted)
  create(:preference, invitation: organizer_inv)
  
  3.times do |i|
    inv = create(:invitation, event: @created_event, invitee_name: "Friend #{i+1}", role: :participant, status: :submitted)
    create(:preference, invitation: inv)
  end
end

Given('AI has generated matches') do
  @created_event.update(status: :ready, ai_generated_at: Time.current)
  create(:activity_suggestion, event: @created_event)
end

