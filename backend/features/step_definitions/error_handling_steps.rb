# Step definitions for error handling and edge cases

When('I submit preferences without activities:') do |table|
  prefs = table.rows_hash
  @invalid_preference = build(:preference,
    invitation: @invitation,
    available_times: prefs['available_times'].split(', '),
    activities: [],  # Empty activities array
    budget_min: prefs['budget_min'].to_i,
    budget_max: prefs['budget_max'].to_i
  )
  @validation_result = @invalid_preference.valid?
end

When('I check if AI can be triggered') do
  @can_trigger_ai = @event.all_preferences_submitted?
end

When('I try to create an event with title longer than {int} characters') do |max_length|
  long_title = 'A' * (max_length + 1)
  @invalid_event = build(:event, title: long_title, organizer: @current_user)
  @validation_result = @invalid_event.valid?
end

When('I try to create an account with name longer than {int} characters') do |max_length|
  long_name = 'A' * (max_length + 1)
  @invalid_user = build(:user, name: long_name)
  @validation_result = @invalid_user.valid?
end

When('I try to create an event with the same share token') do
  existing_event = Event.first
  @duplicate_event = build(:event, 
    organizer: @current_user,
    share_token: existing_event.share_token
  )
  @validation_result = @duplicate_event.valid?
end

When('I submit preferences with equal budget:') do |table|
  prefs = table.rows_hash
  @submitted_preference = create(:preference,
    invitation: @invitation,
    available_times: prefs['available_times'].split(', '),
    activities: prefs['activities'].split(', '),
    budget_min: prefs['budget_min'].to_i,
    budget_max: prefs['budget_max'].to_i
  )
end

Then('AI should not be triggered') do
  expect(@can_trigger_ai).to be false
end

Then('I should see a validation error about missing activities') do
  expect(@validation_result).to be false
  expect(@invalid_preference.errors[:activities]).to be_present
end

Then('I should see a validation error about title length') do
  expect(@validation_result).to be false
  expect(@invalid_event.errors[:title]).to be_present
end

Then('I should see a validation error about name length') do
  expect(@validation_result).to be false
  expect(@invalid_user.errors[:name]).to be_present
end

Then('I should see a validation error about duplicate share token') do
  expect(@validation_result).to be false
  expect(@duplicate_event.errors[:share_token]).to be_present
end

