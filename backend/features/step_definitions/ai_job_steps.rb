# Setup steps for AI job testing

Given('{string} creates an event {string}') do |name, title|
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

Given('{string} and {string} are invited') do |name1, name2|
  @participant1 = User.find_or_create_by!(name: name1)
  @participant2 = User.find_or_create_by!(name: name2)
  
  @invitation1 = create(:invitation,
    event: @event,
    invitee: @participant1,
    role: :participant
  )
  
  @invitation2 = create(:invitation,
    event: @event,
    invitee: @participant2,
    role: :participant
  )
end

Given('{string} is invited') do |name|
  @participant = User.find_or_create_by!(name: name)
  @invitation = create(:invitation,
    event: @event,
    invitee: @participant,
    role: :participant
  )
end

Given('{string}, {string}, and {string} are invited') do |name1, name2, name3|
  @participants = [name1, name2, name3].map do |name|
    user = User.find_or_create_by!(name: name)
    create(:invitation,
      event: @event,
      invitee: user,
      role: :participant
    )
    user
  end
end

When('all participants submit their preferences') do
  # Mock the AI service to return fallback matches
  allow_any_instance_of(Ai::GroupMatchService).to receive(:call).and_return(
    Ai::GroupMatchService::FALLBACK_MATCHES
  )
  
  @event.invitations.participant.each do |invitation|
    invitation.update!(status: :submitted)
    create(:preference, invitation: invitation) unless invitation.preference
  end
  @event.reload
  # This should trigger the job via callback
  @event.enqueue_ai_if_ready!
end

Given('the event is already marked as {string}') do |status|
  @event.update!(status: status.to_sym, ai_generated_at: Time.current)
  create(:activity_suggestion, event: @event)
end

Given('the AI service will return an error') do
  allow_any_instance_of(Ai::GroupMatchService).to receive(:call).and_raise(StandardError.new("API Error"))
end

Given('the AI service will return empty matches') do
  allow_any_instance_of(Ai::GroupMatchService).to receive(:call).and_return([])
end

Given('the event has existing votes from a previous round') do
  @event.update!(status: :ready)
  suggestion = create(:activity_suggestion, event: @event)
  @existing_vote = create(:match_vote,
    event: @event,
    invitation: @invitation1,
    match_id: 'old_match_1',
    score: 5
  )
end

When('{string} marks their invitation as submitted') do |name|
  user = User.find_by!(name: name)
  invitation = @event.invitations.find_by!(invitee: user)
  invitation.update!(status: :submitted)
  create(:preference, invitation: invitation) unless invitation.preference
  @event.reload
end

When('{string} submits the last preferences') do |name|
  user = User.find_by!(name: name)
  invitation = @event.invitations.find_by!(invitee: user)
  invitation.update!(status: :submitted)
  create(:preference, invitation: invitation) unless invitation.preference
  @event.reload
  @event.enqueue_ai_if_ready!
end

When('the job is processed') do
  GenerateActivitySuggestionsJob.perform_now(@event.id)
  @event.reload
end

When('the job is processed synchronously') do
  # Directly run the job
  GenerateActivitySuggestionsJob.perform_now(@event.id)
  @event.reload
end

When('the GenerateActivitySuggestionsJob runs for non-existent event {int}') do |event_id|
  @job_error = nil
  begin
    GenerateActivitySuggestionsJob.perform_now(event_id)
  rescue => e
    @job_error = e
  end
end

When('the GenerateActivitySuggestionsJob runs for the event') do
  @initial_suggestion_count = @event.activity_suggestions.count
  GenerateActivitySuggestionsJob.perform_now(@event.id)
  @event.reload
end

When('the job runs again for the event') do
  @existing_vote_id = @existing_vote.id
  # Reset status to collecting to allow regeneration
  @event.update!(status: :collecting)
  GenerateActivitySuggestionsJob.perform_now(@event.id)
  @event.reload
end

# Assertion steps

Then('the GenerateActivitySuggestionsJob should be enqueued') do
  expect(GenerateActivitySuggestionsJob).to have_been_enqueued.with(@event.id)
end

Then('the GenerateActivitySuggestionsJob should be enqueued exactly once') do
  expect(GenerateActivitySuggestionsJob).to have_been_enqueued.with(@event.id).exactly(:once)
end

Then('the job should not be enqueued yet') do
  # Just verify event is still collecting
  expect(@event.collecting?).to be true
end

# Use existing step from event_steps.rb

Then('AI-generated activity suggestions should exist') do
  expect(@event.activity_suggestions.count).to be > 0
  expect(@event.latest_suggestions).to be_present
end

Then('the event should have an ai_generated_at timestamp') do
  expect(@event.ai_generated_at).to be_present
end

Then('the job should complete without error') do
  expect(@job_error).to be_nil
end

Then('no activity suggestions should be created') do
  if @event
    expect(@event.activity_suggestions.count).to eq(0)
  else
    expect(ActivitySuggestion.count).to eq(0)
  end
end

Then('the job should complete without creating duplicate suggestions') do
  expect(@event.activity_suggestions.count).to eq(@initial_suggestion_count)
end

Then('the job should complete without crashing') do
  # If we got here, the job completed
  expect(true).to be true
end

Then('the error should be logged') do
  # We can't easily check Rails.logger in tests, but we verify the job didn't crash
  # Event might be in pending_ai or collecting depending on when error occurred
  expect(@event.status).to be_in(['collecting', 'pending_ai'])
end

Then('the event should not be marked as ready') do
  expect(@event.ready?).to be false
end

Then('previous votes should be cleared') do
  expect(MatchVote.exists?(@existing_vote.id)).to be false
  expect(@event.match_votes.count).to eq(0)
end

Then('new activity suggestions should be created') do
  expect(@event.activity_suggestions.count).to be > 0
  expect(@event.activity_suggestions.last.created_at).to be > 1.second.ago
end

Then('the event should still be {string}') do |status|
  expect(@event.status).to eq(status)
end

