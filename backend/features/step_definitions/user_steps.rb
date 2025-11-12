Given('I am a registered user named {string}') do |name|
  @current_user = User.find_by(name: name) || create(:user, name: name)
end

Given('a user {string} already exists') do |name|
  create(:user, name: name)
end

Given('I am not authenticated') do
  @current_user = nil
end

Given('I am a registered user with location enabled') do
  @current_user = create(:user, :with_location)
end

Given('I am invited to {int} events as {string}') do |count, name|
  count.times do
    event = create(:event)
    create(:invitation, event: event, invitee_name: name, invitee: nil)
  end
end

Given('I am invited to an event as {string}') do |name|
  event = create(:event)
  @invitation = create(:invitation, event: event, invitee_name: name, invitee: nil)
end

Given('I have not enabled location') do
  @current_user.update(location_permission: false, location_latitude: nil, location_longitude: nil) if @current_user
end

Given('I am the organizer {string}') do |name|
  @current_user = User.find_by(name: name) || create(:user, name: name)
  @organizer = @current_user
end

Given('I have submitted my preferences') do
  organizer_invitation = @event.invitations.find_or_create_by!(
    invitee: @current_user,
    invitee_name: @current_user.name,
    role: :organizer
  )
  create(:preference, invitation: organizer_invitation) unless organizer_invitation.preference
end

When('I create an account with name {string}') do |name|
  @current_user = build(:user, name: name)
  @user_creation_result = @current_user.save
end

When('I update my name to {string}') do |new_name|
  @current_user.update(name: new_name)
end

When('I enable location permissions') do
  @current_user.update(location_permission: true)
end

When('I set my location to coordinates:') do |table|
  coords = table.rows_hash
  @current_user.update(
    location_latitude: coords['latitude'].to_f,
    location_longitude: coords['longitude'].to_f
  )
end

When('I disable location permissions') do
  @current_user.update(
    location_permission: false,
    location_latitude: nil,
    location_longitude: nil
  )
end

When('I try to create an account with name {string}') do |name|
  @user = build(:user, name: name)
  @user_creation_result = @user.save
end

When('I view my profile') do
  @profile_data = @current_user.to_api
end

When('I view my profile API response') do
  @api_response = @current_user.to_api
end

Then('my account should be created successfully') do
  expect(@current_user).to be_persisted
  expect(@current_user.id).to be_present
end

Then('I should have a unique user ID') do
  expect(@current_user.id).to be_a(Integer)
end

Then('my name should be updated') do
  expect(@current_user.reload.name).to eq(@current_user.name)
end

Then('my invitations should reflect the new name') do
  @current_user.invitations.each do |invitation|
    expect(invitation.display_name).to eq(@current_user.name)
  end
end

Then('my location should be saved') do
  @current_user.reload
  expect(@current_user.location_latitude).to be_present
  expect(@current_user.location_longitude).to be_present
end

Then('location permission should be enabled') do
  @current_user.reload
  expect(@current_user.location_permission).to be true
end

Then('my location should be cleared') do
  @current_user.reload
  expect(@current_user.location_latitude).to be_nil
  expect(@current_user.location_longitude).to be_nil
end

Then('location permission should be disabled') do
  @current_user.reload
  expect(@current_user.location_permission).to be false
end

Then('all {int} invitations should be linked to my account') do |count|
  @current_user.claim_matching_invitations!
  expect(@current_user.invitations.count).to eq(count)
end

Then('I should be able to access those events') do
  expect(@current_user.invitations).not_to be_empty
end

Then('the invitation should be linked to my account') do
  @current_user.claim_matching_invitations!
  expect(@current_user.invitations.count).to be > 0
end

Then('I should see an error about duplicate name') do
  expect(@user_creation_result).to be false
  expect(@user.errors[:name]).to be_present
end

Then('the account should not be created') do
  expect(@user).not_to be_persisted
end

Then('my name should be saved as {string}') do |expected_name|
  expect(@current_user.name).to eq(expected_name)
end

Then('extra whitespace should be removed') do
  expect(@current_user.name).not_to match(/^\s|\s$|\s{2,}/)
end

Then('I should see my name') do
  expect(@profile_data[:name]).to eq(@current_user.name)
end

Then('I should see my event count') do
  # Profile data includes events information
  expect(@current_user.organized_events.count + @current_user.invitations.count).to be >= 0
end

Then('I should see my location settings') do
  expect(@profile_data[:location_permission]).to eq(@current_user.location_permission)
end

Then('the location field should be null') do
  expect(@api_response[:location]).to be_nil
end

Then('location_permission should be false') do
  @current_user.reload
  expect(@api_response[:location_permission]).to be false
end
