Feature: Submit Preferences
  As an invited friend
  I want to submit my availability and preferences
  So that the group can find activities that work for everyone

  Background:
    Given an event "Movie Night" exists organized by "Alice"
    And I am invited to the event as "Bob"

  Scenario: Submit preferences for the first time
    When I access my invitation link
    And I submit my preferences:
      | available_times | Friday 7:00 PM, Saturday 8:00 PM |
      | activities      | Movies, Dinner                   |
      | budget_min      | 15                               |
      | budget_max      | 45                               |
      | ideas           | Action or comedy movies          |
    Then my preferences should be saved successfully
    And my invitation status should be "submitted"
    And the event organizer should see my submission

  Scenario: Update previously submitted preferences
    Given I have already submitted my preferences
    When I access my invitation link
    And I update my preferences:
      | available_times | Friday 8:00 PM |
      | activities      | Movies         |
      | budget_min      | 12             |
      | budget_max      | 35             |
      | ideas           | Only comedies  |
    Then my preferences should be updated
    And the submission timestamp should be preserved

  Scenario: Cannot submit preferences with invalid budget range
    When I access my invitation link
    And I submit my preferences with invalid budget:
      | available_times | Friday 7:00 PM |
      | activities      | Movies         |
      | budget_min      | 50             |
      | budget_max      | 20             |
    Then I should see a validation error
    And the error should mention "Budget max must be greater than or equal to budget_min"

  Scenario: Submit preferences without available times
    When I access my invitation link
    And I submit preferences without available times:
      | activities | Movies, Dinner |
      | budget_min | 15             |
      | budget_max | 40             |
    Then I should see a validation error about missing available times

  Scenario: Multiple friends submit preferences
    Given the following friends are invited:
      | Bob     |
      | Charlie |
      | Diana   |
    When "Bob" submits preferences for "Friday 7:00 PM"
    And "Charlie" submits preferences for "Friday 7:00 PM"
    And "Diana" submits preferences for "Saturday 8:00 PM"
    Then the organizer should see 3 submissions
    And the event should still be collecting preferences

  Scenario: Access invitation with invalid token
    When I try to access an invitation with token "invalid-token"
    Then I should receive a not found error

  Scenario: Submit preferences with flexible schedule
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

  Scenario: Claim invitation as registered user
    Given I am a registered user named "Bob"
    When I access my invitation link
    Then my user account should be linked to the invitation
    And my name should be updated to match my account

