Feature: Error Handling and Edge Cases
  As a user of the application
  I want proper error handling
  So that I get clear feedback when something goes wrong

  Background:
    Given I am a registered user named "Alice"

  Scenario: Cannot submit preferences with invalid budget range
    Given an event "Movie Night" exists organized by "Alice"
    And I am invited to the event as "Bob"
    When I access my invitation link
    And I submit my preferences with invalid budget:
      | available_times | Friday 7:00 PM |
      | activities      | Movies         |
      | budget_min      | 50             |
      | budget_max      | 20             |
    Then I should see a validation error
    And the error should mention "Budget max must be greater than or equal to budget_min"

  Scenario: Cannot submit preferences without available times
    Given an event "Movie Night" exists organized by "Alice"
    And I am invited to the event as "Bob"
    When I access my invitation link
    And I submit preferences without available times:
      | activities | Movies, Dinner |
      | budget_min | 15             |
      | budget_max | 40             |
    Then I should see a validation error about missing available times

  Scenario: Cannot submit preferences without activities
    Given an event "Movie Night" exists organized by "Alice"
    And I am invited to the event as "Bob"
    When I access my invitation link
    And I submit preferences without activities:
      | available_times | Friday 7:00 PM |
      | budget_min      | 15             |
      | budget_max      | 40             |
    Then I should see a validation error about missing activities

  Scenario: Access invitation with invalid token
    When I try to access an invitation with token "invalid-token-12345"
    Then I should receive a not found error

  Scenario: Event with no participants cannot trigger AI
    Given I organized an event "Solo Event"
    When I check if AI can be triggered
    Then AI should not be triggered
    And the event status should still be "collecting"

  Scenario: Event with partial preferences cannot trigger AI
    Given I organized an event with 4 participants
    And 2 participants have submitted preferences
    When I check if AI can be triggered
    Then AI should not be triggered
    And the event status should still be "collecting"

  Scenario: Cannot view results before preferences submitted
    Given I organized an event with 4 participants
    And only 2 out of 4 participants have submitted preferences
    When I try to view the event results
    Then the event status should be "collecting"
    And no AI suggestions should be available yet

  Scenario: Event title too long shows validation error
    When I try to create an event with title longer than 120 characters
    Then I should see a validation error about title length

  Scenario: User name too long shows validation error
    When I try to create an account with name longer than 120 characters
    Then I should see a validation error about name length

  Scenario: Cannot access other user's event without permission
    Given "Bob" organized an event "Private Party"
    And I am not invited to the event
    When I try to view the event
    Then I should receive a forbidden error

  Scenario: Update preferences after initial submission
    Given an event "Movie Night" exists organized by "Alice"
    And I am invited to the event as "Bob"
    And I have already submitted my preferences
    When I access my invitation link
    And I update my preferences:
      | available_times | Friday 8:00 PM |
      | activities      | Movies         |
      | budget_min      | 12             |
      | budget_max      | 35             |
      | ideas           | Only comedies  |
    Then my preferences should be updated
    And the submission timestamp should be preserved

  Scenario: Handle duplicate share tokens gracefully
    Given an event "Event 1" exists
    When I try to create an event with the same share token
    Then I should see a validation error about duplicate share token

  Scenario: AI generates fallback matches on error
    Given all participants have submitted their preferences
    When the AI service encounters an error
    Then fallback activity suggestions should be provided
    And the event status should still be "ready"
    And users should see at least 3 activity options

  Scenario: Submit preferences with very flexible schedule
    Given an event "Flexible Plans" exists organized by "Alice"
    And I am invited to the event as "Bob"
    When I access my invitation link
    And I submit preferences with many time slots:
      | Monday 6:00 PM    |
      | Tuesday 6:00 PM   |
      | Wednesday 6:00 PM |
      | Thursday 6:00 PM  |
      | Friday 6:00 PM    |
      | Saturday All Day  |
      | Sunday All Day    |
    Then all time slots should be saved correctly

  Scenario: Submit preferences with minimum budget equal to maximum
    Given an event "Budget Test" exists organized by "Alice"
    And I am invited to the event as "Bob"
    When I submit preferences with equal budget:
      | available_times | Saturday 2:00 PM |
      | activities      | Coffee           |
      | budget_min      | 25               |
      | budget_max      | 25               |
    Then my preferences should be saved successfully

  Scenario: Claim invitation as registered user
    Given an event "Team Lunch" exists organized by "Alice"
    And I am invited to the event as "Bob"
    And I am a registered user named "Bob"
    When I access my invitation link
    Then my user account should be linked to the invitation
    And my name should be updated to match my account

