Given('the following friends are invited:') do |table|
  @invited_participants = []
  table.raw.flatten.each do |friend_name|
    invitation = create(:invitation, event: @event, invitee_name: friend_name, role: :participant)
    @invited_participants << { name: friend_name, invitation: invitation }
  end
end

Given('I have already submitted my preferences') do
  @my_preference = create(:preference, invitation: @invitation)
end

Given('the organizer {string} has submitted preferences:') do |name, table|
  organizer = User.find_by(name: name)
  organizer_invitation = @event.invitations.find_or_create_by!(
    invitee: organizer,
    invitee_name: name,
    role: :organizer
  )
  
  prefs = table.rows_hash
  create(:preference,
    invitation: organizer_invitation,
    available_times: prefs['available_times'].split(', '),
    activities: prefs['activities'].split(', '),
    budget_min: prefs['budget_min'].to_i,
    budget_max: prefs['budget_max'].to_i,
    ideas: prefs['ideas']
  )
end

Given('{string} has submitted preferences:') do |name, table|
  invitation = @invited_participants.find { |p| p[:name] == name }&.dig(:invitation)
  invitation ||= @event.invitations.find_or_create_by!(invitee_name: name, role: :participant)
  
  prefs = table.rows_hash
  create(:preference,
    invitation: invitation,
    available_times: prefs['available_times'].split(', '),
    activities: prefs['activities'].split(', '),
    budget_min: prefs['budget_min'].to_i,
    budget_max: prefs['budget_max'].to_i,
    ideas: prefs['ideas']
  )
  
  invitation.mark_submitted!
end

Given('{string} prefers {string}') do |name, preference_value|
  user = User.find_by(name: name) || create(:user, name: name)
  # Find any existing invitation for this user (organizer or participant)
  invitation = @event.invitations.find_by(invitee_name: name) || 
                @event.invitations.find_by(invitee: user) ||
                create(:invitation, event: @event, invitee_name: name, invitee: user)
  
  # Store for later use
  @user_preferences ||= {}
  @user_preferences[name] ||= { times: [], activities: [] }
  @user_preferences[name][:times] << preference_value if preference_value.include?('PM') || preference_value.include?('AM')
  @user_preferences[name][:activities] << preference_value unless preference_value.include?('PM') || preference_value.include?('AM')
end

When('I access my invitation link') do
  @accessed_invitation = @invitation
end

When('I submit my preferences:') do |table|
  prefs = table.rows_hash
  @submitted_preference = create(:preference,
    invitation: @invitation,
    available_times: prefs['available_times'].split(', '),
    activities: prefs['activities'].split(', '),
    budget_min: prefs['budget_min'].to_i,
    budget_max: prefs['budget_max'].to_i,
    ideas: prefs['ideas']
  )
end

When('I update my preferences:') do |table|
  prefs = table.rows_hash
  @my_preference.update(
    available_times: prefs['available_times'].split(', '),
    activities: prefs['activities'].split(', '),
    budget_min: prefs['budget_min'].to_i,
    budget_max: prefs['budget_max'].to_i,
    ideas: prefs['ideas']
  )
end

When('I submit my preferences with invalid budget:') do |table|
  prefs = table.rows_hash
  @invalid_preference = build(:preference,
    invitation: @invitation,
    available_times: prefs['available_times'].split(', '),
    activities: prefs['activities'].split(', '),
    budget_min: prefs['budget_min'].to_i,
    budget_max: prefs['budget_max'].to_i
  )
  @validation_result = @invalid_preference.valid?
end

When('I submit preferences without available times:') do |table|
  prefs = table.rows_hash
  @invalid_preference = build(:preference,
    invitation: @invitation,
    available_times: [],
    activities: prefs['activities'].split(', '),
    budget_min: prefs['budget_min'].to_i,
    budget_max: prefs['budget_max'].to_i
  )
  @validation_result = @invalid_preference.valid?
end

When('{string} submits preferences for {string}') do |name, time_slot|
  participant = @invited_participants.find { |p| p[:name] == name }
  invitation = participant[:invitation]
  create(:preference, invitation: invitation, available_times: [time_slot])
end

When('{string} submits the last preferences:') do |name, table|
  invitation = @invited_participants.find { |p| p[:name] == name }&.dig(:invitation)
  invitation ||= @event.invitations.find_by(invitee_name: name)
  
  prefs = table.rows_hash
  create(:preference,
    invitation: invitation,
    available_times: prefs['available_times'].split(', '),
    activities: prefs['activities'].split(', '),
    budget_min: prefs['budget_min'].to_i,
    budget_max: prefs['budget_max'].to_i,
    ideas: prefs['ideas']
  )
end

When('I try to access an invitation with token {string}') do |token|
  @found_invitation = Invitation.find_by(access_token: token)
end

When('I submit preferences with many time slots:') do |table|
  time_slots = table.raw.flatten
  @submitted_preference = create(:preference,
    invitation: @invitation,
    available_times: time_slots,
    activities: ['Flexible'],
    budget_min: 10,
    budget_max: 50
  )
end

When('{string} submits preferences') do |name|
  invitation = @event.invitations.find_by(invitee_name: name)
  unless invitation
    user = User.find_by(name: name)
    invitation = create(:invitation, event: @event, invitee: user, invitee_name: name)
  end
  create(:preference, invitation: invitation) unless invitation.preference
end

When('all preferences are submitted') do
  @event.invitations.each do |invitation|
    next if invitation.preference
    
    # Use stored user preferences if available
    if @user_preferences && @user_preferences[invitation.invitee_name]
      prefs = @user_preferences[invitation.invitee_name]
      create(:preference, 
        invitation: invitation,
        available_times: prefs[:times].presence || ['Monday 6:00 PM'],
        activities: prefs[:activities].presence || ['Coffee']
      )
    else
      # For invitations without specified preferences, use unique default times
      create(:preference, 
        invitation: invitation,
        available_times: ['Monday 6:00 PM'],  # Different from common test times
        activities: ['Coffee']
      )
    end
  end
end

When('I view {string} preferences') do |name|
  clean_name = name.gsub(/['']s$/, '')
  invitation = @event.invitations.find_by('invitee_name ILIKE ?', clean_name)
  @viewed_preference = invitation&.preference
end

When('I view the aggregate preferences') do
  @aggregate_prefs = @event.aggregate_preferences
  @time_tallies = @event.preferences.flat_map(&:available_times).tally
end

Then('my preferences should be saved successfully') do
  expect(@submitted_preference).to be_persisted
  expect(@submitted_preference.invitation).to eq(@invitation)
end

Then('my invitation status should be {string}') do |status|
  expect(@invitation.reload.status).to eq(status)
end

Then('the event organizer should see my submission') do
  expect(@event.progress_snapshot.any? { |p| p[:status] == 'submitted' }).to be true
end

Then('my preferences should be updated') do
  expect(@my_preference.reload).to be_present
end

Then('the submission timestamp should be preserved') do
  expect(@my_preference.submitted_at).to be_present
end

Then('I should see a validation error') do
  expect(@validation_result).to be false
  expect(@invalid_preference.errors).not_to be_empty
end

Then('the error should mention {string}') do |error_message|
  expect(@invalid_preference.errors.full_messages.join).to include(error_message)
end

Then('I should see a validation error about missing available times') do
  expect(@validation_result).to be false
  expect(@invalid_preference.errors[:available_times]).to be_present
end

Then('the organizer should see {int} submissions') do |count|
  expect(@event.invitations.submitted.count).to eq(count)
end

Then('the event should still be collecting preferences') do
  expect(@event.status).to eq('collecting')
end

Then('I should receive a not found error') do
  expect(@found_invitation).to be_nil
end

Then('all time slots should be saved correctly') do
  expect(@submitted_preference.available_times.length).to be > 5
end

Then('my user account should be linked to the invitation') do
  expect(@invitation.reload.invitee).to eq(@current_user)
end

Then('my name should be updated to match my account') do
  expect(@invitation.reload.invitee_name).to eq(@current_user.name)
end

Then('I should see his available times') do
  expect(@viewed_preference&.available_times).to be_present
end

Then('I should see his activity choices') do
  expect(@viewed_preference&.activities).to be_present
end

Then('I should see his budget range') do
  expect(@viewed_preference&.budget_min).to be_present
  expect(@viewed_preference&.budget_max).to be_present
end

Then('I should see his ideas and notes') do
  expect(@viewed_preference&.ideas).to be_present
end

Then('each preference should show available times and activities') do
  @event.aggregate_preferences.each do |pref|
    expect(pref[:available_times]).to be_present
    expect(pref[:activities]).to be_present
  end
end

Then('{string} should show {int} votes') do |item, votes|
  # Check in the time tallies
  expect(@time_tallies[item]).to eq(votes)
end

