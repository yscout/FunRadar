# Voting setup steps
Given('{string} has organized an event {string}') do |name, title|
  @organizer = User.find_or_create_by!(name: name)
  @event = create(:event, title: title, organizer: @organizer)
  @organizer_invitation = create(:invitation, 
    event: @event, 
    invitee: @organizer, 
    role: :organizer, 
    status: :submitted
  )
  create(:preference, invitation: @organizer_invitation)
end

Given('{string} and {string} are invited to the event') do |name1, name2|
  @participant1 = User.find_or_create_by!(name: name1)
  @participant2 = User.find_or_create_by!(name: name2)
  
  @invitation1 = create(:invitation,
    event: @event,
    invitee: @participant1,
    invitee_name: name1,
    role: :participant
  )
  
  @invitation2 = create(:invitation,
    event: @event,
    invitee: @participant2,
    invitee_name: name2,
    role: :participant
  )
end

Given('{string} is invited to the event') do |name|
  @participant = User.find_or_create_by!(name: name)
  @invitation = create(:invitation,
    event: @event,
    invitee: @participant,
    invitee_name: name,
    role: :participant
  )
end

# Use the existing step from ai_matching_steps.rb

Given('{string} has submitted preferences') do |name|
  user = User.find_by!(name: name)
  invitation = @event.invitations.find_by!(invitee: user)
  invitation.update!(status: :submitted)
  create(:preference, invitation: invitation) unless invitation.preference
end

Given('AI has generated activity suggestions') do
  @event.update!(status: :ready, ai_generated_at: Time.current)
  @suggestion = create(:activity_suggestion, 
    event: @event,
    payload: [
      { 'id' => 'match_1', 'name' => 'Beach Volleyball', 'price' => '$25' },
      { 'id' => 'match_2', 'name' => 'Mini Golf', 'price' => '$15' },
      { 'id' => 'match_3', 'name' => 'Bowling', 'price' => '$20' }
    ]
  )
end

Given('{string} has already voted on match_1 with score {int}') do |name, score|
  user = User.find_by!(name: name)
  invitation = @event.invitations.find_by!(invitee: user)
  create(:match_vote, 
    invitation: invitation,
    event: @event,
    match_id: 'match_1',
    score: score
  )
end

Given('{string} is a registered user') do |name|
  @non_participant = User.find_or_create_by!(name: name)
end

# Voting action steps
When('{string} votes on the suggestions with scores:') do |name, table|
  user = User.find_by!(name: name)
  votes_data = table.hashes.map do |row|
    { match_id: row['match_id'], score: row['score'].to_i }
  end
  
  headers = {
    'CONTENT_TYPE' => 'application/json',
    'HTTP_X_USER_ID' => user.id.to_s
  }
  
  post "/api/events/#{@event.id}/votes", 
    { votes: votes_data }.to_json, 
    headers
  
  @last_response_status = last_response.status
  @last_response_body = last_response.body
  @last_response_json = JSON.parse(@last_response_body) rescue {}
  @current_voter = user
end

When('{string} attempts to vote on the suggestions') do |name|
  user = User.find_by!(name: name)
  votes_data = [{ match_id: 'match_1', score: 5 }]
  
  headers = {
    'CONTENT_TYPE' => 'application/json',
    'HTTP_X_USER_ID' => user.id.to_s
  }
  
  post "/api/events/#{@event.id}/votes", 
    { votes: votes_data }.to_json, 
    headers
  
  @last_response_status = last_response.status
  @last_response_body = last_response.body
  @last_response_json = JSON.parse(@last_response_body) rescue {}
  @current_voter = user
end

When('{string} attempts to vote on the event') do |name|
  user = User.find_by!(name: name)
  votes_data = [{ match_id: 'match_1', score: 5 }]
  
  headers = {
    'CONTENT_TYPE' => 'application/json',
    'HTTP_X_USER_ID' => user.id.to_s
  }
  
  post "/api/events/#{@event.id}/votes", 
    { votes: votes_data }.to_json, 
    headers
  
  @last_response_status = last_response.status
  @last_response_body = last_response.body
  @last_response_json = JSON.parse(@last_response_body) rescue {}
  @current_voter = user
end

# Voting assertion steps
Then('Bob should see his votes recorded') do
  expect(@last_response_status).to eq(200)
  expect(@last_response_json).to have_key('user_votes')
  expect(@last_response_json['user_votes']).to be_a(Hash)
  expect(@last_response_json['user_votes'].keys.length).to be > 0
end

Then('the event should have voting data') do
  expect(@last_response_json).to have_key('votes_summary')
end

Then('the votes summary should show combined scores') do
  expect(@last_response_json).to have_key('votes_summary')
  expect(@last_response_json['votes_summary']).to be_a(Hash)
end

Then('match_1 should have total score of {int}') do |expected_score|
  votes_summary = @last_response_json['votes_summary']
  expect(votes_summary['match_1']['total_score']).to eq(expected_score)
end

Then('match_2 should have total score of {int}') do |expected_score|
  votes_summary = @last_response_json['votes_summary']
  expect(votes_summary['match_2']['total_score']).to eq(expected_score)
end

Then('Bob should see his updated vote for match_1 as {int}') do |expected_score|
  expect(@last_response_status).to eq(200)
  user_votes = @last_response_json['user_votes']
  expect(user_votes['match_1'].to_i).to eq(expected_score)
end

Then('Bob should see an error {string}') do |error_message|
  expect(@last_response_json).to have_key('error')
  expect(@last_response_json['error']).to eq(error_message)
end

Then('Charlie should see an error {string}') do |error_message|
  expect(@last_response_json).to have_key('error')
  expect(@last_response_json['error']).to eq(error_message)
end

Then('the event should be completed after voting') do
  @event.reload
  expect(@event.status).to eq('completed')
  expect(@event.completed_at).to be_present
end

Then('the event final match should be stored') do
  @event.reload
  expect(@event.final_match).to be_present
  expect(@event.final_match).to have_key('id')
end

# Use the existing step from api_controller_steps.rb
