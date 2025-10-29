Feature: View Events
  As a user
  I want to view my events
  So that I can track hangout plans I'm organizing or invited to

  Background:
    Given I am a registered user named "Alice"

  Scenario: View all my events
    Given I have organized 2 events
    And I am invited to 3 events
    When I view my events list
    Then I should see 5 events total
    And each event should show its title and status

  Scenario: View event details as organizer
    Given I organized an event "Pizza Night"
    When I view the event details
    Then I should see the event title "Pizza Night"
    And I should see my organizer status
    And I should see all invited participants
    And I should see submission progress

  Scenario: View event details as participant
    Given "Bob" organized an event "Game Night"
    And I am invited to the event
    When I view the event details
    Then I should see the event title "Game Night"
    And I should see the organizer name "Bob"
    And I should see my invitation status

  Scenario: View event progress as organizer
    Given I organized an event with 4 participants
    And 2 participants have submitted preferences
    When I check the event progress
    Then I should see "2 out of 4" submissions
    And I should see who has submitted
    And I should see who is pending

  Scenario: View event with share token
    Given an event "Public Meetup" exists
    And I have the event's share token
    When I access the event using the share token
    Then I should see the event details
    And I should not need authentication

  Scenario: Cannot view event without permission
    Given "Bob" organized an event "Private Party"
    And I am not invited to the event
    When I try to view the event
    Then I should receive a forbidden error

  Scenario: View completed event with results
    Given I organized an event "Weekend Trip"
    And all participants have submitted preferences
    And AI suggestions have been generated
    When I view the event results
    Then I should see activity suggestions
    And each suggestion should show compatibility score
    And I should see all participants' preferences

  Scenario: Filter events by status
    Given I have events with different statuses:
      | Weekend Brunch | collecting |
      | Movie Night    | pending_ai |
      | Beach Day      | ready      |
    When I filter events by status "ready"
    Then I should see only "Beach Day"

  Scenario: View empty events list
    Given I have no events
    When I view my events list
    Then I should see an empty state
    And I should see a button to create new event

  Scenario: View event timeline
    Given I organized an event "Dinner Party" 2 days ago
    And participants submitted preferences 1 day ago
    And AI generated suggestions 1 hour ago
    When I view the event timeline
    Then I should see events in chronological order
    And each event should show timestamp

