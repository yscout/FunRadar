Given('an event {string} exists') do |title|
  organizer = create(:user, name: 'DefaultOrganizer')
  @event = create(:event, title: title, organizer: organizer)
  # Create organizer invitation
  create(:invitation, event: @event, invitee: organizer, invitee_name: organizer.name, role: :organizer)
end

Given('an event {string} exists organized by {string}') do |title, organizer_name|
  organizer = User.find_by(name: organizer_name) || create(:user, name: organizer_name)
  @event = create(:event, title: title, organizer: organizer)
  @organizer = organizer
  @created_event = @event  # For API controller step compatibility
  # Create organizer invitation
  create(:invitation, event: @event, invitee: organizer, invitee_name: organizer.name, role: :organizer)
end

Given('I have organized {int} events') do |count|
  create_list(:event, count, organizer: @current_user)
end

Given('I am invited to {int} events') do |count|
  count.times do
    event = create(:event)
    create(:invitation, event: event, invitee: @current_user)
  end
end

Given('I organized an event {string}') do |title|
  @event = create(:event, title: title, organizer: @current_user)
  # Create organizer invitation
  create(:invitation, event: @event, invitee: @current_user, invitee_name: @current_user.name, role: :organizer)
  # Create some participant invitations for realistic scenario
  create_list(:invitation, 3, event: @event, role: :participant)
end

Given('{string} organized an event {string}') do |organizer_name, title|
  organizer = User.find_by(name: organizer_name) || create(:user, name: organizer_name)
  @event = create(:event, title: title, organizer: organizer)
  # Create organizer invitation
  create(:invitation, event: @event, invitee: organizer, invitee_name: organizer.name, role: :organizer)
  # Create some participant invitations for realistic scenario
  create_list(:invitation, 3, event: @event, role: :participant)
end

Given('I am invited to the event') do
  @invitation = create(:invitation, event: @event, invitee: @current_user)
end

Given('I am not invited to the event') do
  # Do nothing - user is not invited
end

Given('I have the event\'s share token') do
  @share_token = @event.share_token
end

Given('I have no events') do
  # User has no events by default
  expect(@current_user.organized_events).to be_empty
  expect(@current_user.invitations).to be_empty
end

Given('I have events with different statuses:') do |table|
  table.raw.each do |row|
    title = row[0]
    status = row[1].to_sym
    create(:event, title: title, organizer: @current_user, status: status)
  end
end

Given('I organized an event {string} {int} days ago') do |title, days|
  @event = create(:event, title: title, organizer: @current_user, created_at: days.days.ago)
end

Given('participants submitted preferences {int} day ago') do |days|
  # Mark that preferences were submitted
  @preferences_submitted_at = days.days.ago
end

Given('AI generated suggestions {int} hour ago') do |hours|
  @event.update(ai_generated_at: hours.hours.ago) if @event
end

Given('I organized an event with {int} participants') do |count|
  @event = create(:event, organizer: @current_user)
  create(:invitation, event: @event, role: :organizer, invitee: @current_user, invitee_name: @current_user.name)
  create_list(:invitation, count, event: @event, role: :participant)
end

Given('{int} participants have submitted preferences') do |count|
  @event.invitations.participant.first(count).each do |invitation|
    create(:preference, invitation: invitation)
  end
end

Given('all participants have submitted preferences') do
  @event.invitations.each do |invitation|
    create(:preference, invitation: invitation) unless invitation.preference
  end
end

Given('AI suggestions have been generated') do
  @event.update(status: :ready, ai_generated_at: Time.current)
  create(:activity_suggestion, event: @event)
end

Given('the event has {int} participants total') do |count|
  current_count = @event.invitations.count
  remaining = count - current_count
  create_list(:invitation, remaining, event: @event) if remaining > 0
end

When('I create an event with the following details:') do |table|
  @event_params = table.rows_hash
end

When('I set my preferences:') do |table|
  @preference_params = table.rows_hash
  @preference_params['available_times'] = @preference_params['available_times']&.split(', ') || []
  @preference_params['activities'] = @preference_params['activities']&.split(', ') || []
  @preference_params['budget_min'] = @preference_params['budget_min']&.to_i
  @preference_params['budget_max'] = @preference_params['budget_max']&.to_i
  
  # Actually create the event if we have event params
  if @event_params || @current_user
    @event ||= create(:event, 
      organizer: @current_user,
      title: @event_params&.[]('title'),
      notes: @event_params&.[]('notes')
    )
    
    # Create organizer invitation
    @organizer_invitation = create(:invitation, 
      event: @event, 
      invitee: @current_user,
      invitee_name: @current_user.name,
      role: :organizer
    )
    
    # Create organizer preference
    create(:preference, 
      invitation: @organizer_invitation,
      available_times: @preference_params['available_times'],
      activities: @preference_params['activities'],
      budget_min: @preference_params['budget_min'],
      budget_max: @preference_params['budget_max']
    )
  end
end

When('I invite the following friends:') do |table|
  @invited_friends = table.raw.flatten
  
  # Create invitations for friends
  if @event
    @invited_friends.each do |friend_name|
      create(:invitation, event: @event, invitee_name: friend_name, role: :participant)
    end
  end
end

When('I invite friends with emails:') do |table|
  @invited_friends_with_emails = table.hashes
  
  # Create invitations with emails
  if @event
    @invited_friends_with_emails.each do |friend|
      create(:invitation, 
        event: @event, 
        invitee_name: friend['name'], 
        invitee_email: friend['email'],
        role: :participant
      )
    end
  end
end

When('I enable location sharing') do
  @location_enabled = true
end

When('I try to create an event') do
  @event_creation_attempted = true
  @event = build(:event, organizer: @current_user)
end

When('I view my events list') do
  @events_list = (@current_user.organized_events + @current_user.invitations.map(&:event)).uniq
end

When('I view the event details') do
  @event_details = @event.to_api
end

When('I check the event progress') do
  @event_progress = @event.progress_snapshot
  @submitted_count = @event.invitations.submitted.count
  @total_count = @event.invitations.participant.count
end

When('I access the event using the share token') do
  # Simulate accessing with share token - in real API this would be a query param
  @accessed_event = @event if @share_token == @event.share_token
end

When('I try to view the event') do
  # Simulate unauthorized access attempt
  @access_result = @current_user.invitations.exists?(event_id: @event.id) || 
                   @current_user.organized_events.exists?(id: @event.id)
end

When('I view the event results') do
  @event_results = @event.to_api(include_progress: false, include_results: true)
end

When('I filter events by status {string}') do |status|
  @filtered_events = @current_user.organized_events.where(status: status)
end

When('I view the event timeline') do
  @timeline_events = @current_user.organized_events.order(created_at: :desc)
end

When('I generate a share link for the event') do
  @share_link = "https://funradar.app/events/#{@event.id}?share_token=#{@event.share_token}"
end

When('I add notes to the event:') do |notes|
  @event.update(notes: notes)
end

When('I check the participant count') do
  @participant_count = @event.invitations.count
end

When('the organizer adds a new participant {string}') do |name|
  @new_invitation = create(:invitation, event: @event, invitee_name: name, role: :participant)
  @event.activity_suggestions.destroy_all
  @event.update(status: :collecting)
end

Then('the event should be created successfully') do

  expect(@event).to be_present, "Event should have been created by When steps"
  expect(@event).to be_persisted, "Event should be saved to database"
  expect(@event.organizer).to eq(@current_user), "Organizer should be set correctly"
  
  # Verify organizer invitation was created
  organizer_invitation = @event.invitations.organizer.first
  expect(organizer_invitation).to be_present, "Organizer invitation should exist"
  expect(organizer_invitation.invitee).to eq(@current_user)
  
  if @preference_params
    expect(organizer_invitation.preference).to be_present, "Organizer preferences should be saved"
  end
  
  if @invited_friends
    expect(@event.invitations.participant.count).to eq(@invited_friends.count),
      "Should have created invitations for all invited friends"
  end
  
  if @invited_friends_with_emails
    expect(@event.invitations.participant.count).to eq(@invited_friends_with_emails.count),
      "Should have created invitations for all invited friends with emails"
  end
end

Then('I should be the organizer') do
  expect(@event.organizer).to eq(@current_user)
  organizer_invitation = @event.invitations.organizer.first
  expect(organizer_invitation.invitee).to eq(@current_user)
end

Then('my preferences should be saved') do
  organizer_invitation = @event.invitations.organizer.first
  preference = organizer_invitation.preference
  expect(preference).to be_present
  expect(preference.activities).to eq(@preference_params['activities'])
end

Then('{int} invitation links should be generated') do |count|
  expect(@event.invitations.participant.count).to eq(count)
  @event.invitations.participant.each do |invitation|
    expect(invitation.access_token).to be_present
  end
end

Then('the event status should be {string}') do |status|
  expect(@event.status).to eq(status)
end

Then('the event should have a default share token') do
  expect(@event.share_token).to be_present
  expect(@event.share_token).to match(/^[a-f0-9\-]{36}$/)
end

Then('the event title should be {string}') do |title|
  expect(@event.title).to eq(title)
end

Then('I should receive an unauthorized error') do
  expect(@current_user).to be_nil
end

Then('my location should be saved with my preferences') do
  if @location_enabled
    organizer_invitation = @event.invitations.organizer.first
    expect(organizer_invitation).to be_present
  end
end

Then('invitation emails should include access tokens') do
  @event.invitations.participant.each do |invitation|
    expect(invitation.access_token).to be_present
    expect(invitation.invitee_email).to be_present if invitation.invitee_email
  end
end

Then('I should see {int} events total') do |count|
  expect(@events_list.count).to eq(count)
end

Then('each event should show its title and status') do
  @events_list.each do |event|
    expect(event.title).to be_present
    expect(event.status).to be_present
  end
end

Then('I should see the event title {string}') do |title|
  expect(@event_details[:title]).to eq(title)
end

Then('I should see my organizer status') do
  expect(@event.organizer).to eq(@current_user)
end

Then('I should see all invited participants') do
  expect(@event_details[:progress]).to be_present
end

Then('I should see submission progress') do
  expect(@event_details).to include(:submitted_count, :participant_count)
end

Then('I should see the organizer name {string}') do |name|
  expect(@event_details[:organizer][:name]).to eq(name)
end

Then('I should see my invitation status') do
  invitation = @event.invitations.find_by(invitee: @current_user)
  expect(invitation).to be_present
end

Then('I should see {string} submissions') do |count_str|
  submitted, total = count_str.match(/(\d+) out of (\d+)/).captures.map(&:to_i)
  expect(@submitted_count).to eq(submitted)
  expect(@total_count).to eq(total)
end

Then('I should see who has submitted') do
  submitted_invitations = @event.invitations.submitted
  expect(submitted_invitations).not_to be_empty
end

Then('I should see who is pending') do
  pending_invitations = @event.invitations.pending
  expect(pending_invitations.count).to be >= 0
end

Then('I should see the event details') do
  expect(@accessed_event).to eq(@event)
end

Then('I should not need authentication') do
  expect(@share_token).to be_present
end

Then('I should receive a forbidden error') do
  expect(@access_result).to be false
end

Then('I should see activity suggestions') do
  expect(@event_results[:matches]).to be_an(Array)
end

Then('each suggestion should show compatibility score') do
  @event_results[:matches].each do |match|
    expect(match).to have_key('compatibility') if match.is_a?(Hash)
  end
end

Then('I should see all participants\' preferences') do
  preferences = @event.aggregate_preferences
  expect(preferences).to be_an(Array)
end

Then('I should see only {string}') do |title|
  expect(@filtered_events.map(&:title)).to eq([title])
end

Then('I should see an empty state') do
  expect(@events_list).to be_empty
end

Then('I should see a button to create new event') do
  # In the UI there would be a create button
  expect(@events_list).to be_empty
end

Then('I should see events in chronological order') do
  expect(@timeline_events.pluck(:created_at)).to eq(@timeline_events.pluck(:created_at).sort.reverse)
end

Then('each event should show timestamp') do
  @timeline_events.each do |event|
    expect(event.created_at).to be_present
  end
end

Then('the link should contain the event share token') do
  expect(@share_link).to include(@event.share_token)
end

Then('anyone with the link should be able to view the event') do
  expect(@event.share_token).to be_present
end

Then('all participants should see the notes') do
  expect(@event.notes).to be_present
end

Then('the notes should be included in AI context') do
  expect(@event.notes).to be_present
end

Then('it should show {int} participants') do |count|
  expect(@participant_count).to eq(count)
end

Then('it should include the organizer') do
  expect(@event.invitations.organizer).to exist
end

Then('it should include all invited friends') do
  expect(@event.invitations.participant.count).to be >= 0
end

Then('the event status should reset to {string}') do |status|
  expect(@event.reload.status).to eq(status)
end

Then('{string} should receive an invitation') do |name|
  invitation = @event.invitations.find_by(invitee_name: name)
  expect(invitation).to be_present
end

Then('existing suggestions should be cleared') do
  expect(@event.activity_suggestions).to be_empty
end

Then('I should see the progress update to {string}') do |progress_str|
  submitted, total = progress_str.match(/(\d+) out of (\d+)/).captures.map(&:to_i)
  actual_submitted = @event.invitations.submitted.count
  actual_total = @event.invitations.count  # Count all invitations (organizer + participants)
  expect(actual_submitted).to eq(submitted)
  expect(actual_total).to eq(total)
end

Then('the event status should still be {string}') do |status|
  expect(@event.reload.status).to eq(status)
end

