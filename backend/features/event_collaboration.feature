Feature: Event Collaboration
  As a group member
  I want to collaborate with others on event planning
  So that we can make decisions together

  Background:
    Given an event "Summer Picnic" exists organized by "Alice"
    And the following friends are invited:
      | Bob     |
      | Charlie |
      | Diana   |

  Scenario: Real-time progress tracking
    Given I am the organizer "Alice"
    And I have submitted my preferences
    When "Bob" submits preferences
    Then I should see the progress update to "2 out of 4"
    When "Charlie" submits preferences
    Then I should see the progress update to "3 out of 4"

  Scenario: Share event link with new participants
    Given I am the organizer "Alice"
    When I generate a share link for the event
    Then the link should contain the event share token
    And anyone with the link should be able to view the event

  Scenario: Participant sees other preferences after AI processing
    Given all participants have submitted preferences
    And AI has generated suggestions
    When I view the event results as "Bob"
    Then I should see preferences from:
      | Alice   |
      | Bob     |
      | Charlie |
      | Diana   |
    And each preference should show available times and activities

  Scenario: Compare preferences overlap
    Given "Alice" prefers "Saturday 3:00 PM"
    And "Bob" prefers "Saturday 3:00 PM"
    And "Charlie" prefers "Sunday 10:00 AM"
    When all preferences are submitted
    And I view the aggregate preferences
    Then "Saturday 3:00 PM" should show 2 votes
    And "Sunday 10:00 AM" should show 1 vote

  Scenario: Add late participant
    Given all 4 participants have submitted preferences
    And AI has generated suggestions
    When the organizer adds a new participant "Eve"
    Then the event status should reset to "collecting"
    And "Eve" should receive an invitation
    And existing suggestions should be cleared

  Scenario: Group activity voting
    Given AI has suggested 5 activities
    When participants vote on activities:
      | Bob     | Activity 1 |
      | Charlie | Activity 1 |
      | Diana   | Activity 2 |
      | Alice   | Activity 1 |
    Then "Activity 1" should have 3 votes
    And "Activity 2" should have 1 vote
    And the top-voted activity should be highlighted

  Scenario: View individual preference details
    Given all participants have submitted preferences
    When I view "Bob's" preferences
    Then I should see his available times
    And I should see his activity choices
    And I should see his budget range
    And I should see his ideas and notes

  Scenario: Event notes and communication
    Given I am the organizer "Alice"
    When I add notes to the event:
      """
      Looking forward to seeing everyone!
      Don't forget sunscreen if we go to the beach.
      """
    Then all participants should see the notes
    And the notes should be included in AI context

  Scenario: Participant count accuracy
    Given the event has 4 participants total
    When I check the participant count
    Then it should show 4 participants
    And it should include the organizer
    And it should include all invited friends

