Feature: AI Activity Matching
  As a group of friends
  We want AI to analyze our preferences and suggest activities
  So that we can quickly decide what to do together

  Background:
    Given an event "Weekend Fun" exists organized by "Alice"
    And the following friends are invited:
      | Bob     |
      | Charlie |
      | Diana   |

  Scenario: Generate suggestions when all preferences are submitted
    Given the organizer "Alice" has submitted preferences:
      | available_times | Saturday 3:00 PM, Sunday 10:00 AM |
      | activities      | Picnic, Coffee, Dinner            |
      | budget_min      | 15                                |
      | budget_max      | 60                                |
      | ideas           | Love outdoor activities           |
    And "Bob" has submitted preferences:
      | available_times | Saturday 2:00 PM, Saturday 3:00 PM |
      | activities      | Picnic, Dinner                     |
      | budget_min      | 20                                 |
      | budget_max      | 70                                 |
      | ideas           | Something casual and fun           |
    And "Charlie" has submitted preferences:
      | available_times | Saturday 3:00 PM, Sunday 10:00 AM |
      | activities      | Coffee, Picnic, Dinner            |
      | budget_min      | 10                                |
      | budget_max      | 50                                |
      | ideas           | Prefer something affordable       |
    When "Diana" submits the last preferences:
      | available_times | Saturday 3:00 PM, Sunday 2:00 PM |
      | activities      | Dinner, Picnic                   |
      | budget_min      | 25                               |
      | budget_max      | 80                               |
      | ideas           | Really into food experiences     |
    Then the AI matching job should be triggered
    And the event status should change to "pending_ai"

  Scenario: AI generates activity suggestions
    Given all participants have submitted their preferences
    When the AI processes the group preferences
    Then 3 to 5 activity suggestions should be generated
    And each suggestion should include:
      | title         |
      | compatibility |
      | location      |
      | price         |
      | time          |
      | description   |
      | emoji         |
    And the event status should be "ready"

  Scenario: AI considers overlapping time slots
    Given all participants prefer "Saturday 3:00 PM"
    When the AI processes the group preferences
    Then the suggested activities should be scheduled for "Saturday 3:00 PM"

  Scenario: AI respects budget constraints
    Given all participants have budget range between $10 and $50
    When the AI processes the group preferences
    Then suggested activities should be within budget range
    And expensive options above $50 should not be suggested

  Scenario: AI prioritizes popular activities
    Given 3 participants prefer "Dinner"
    And 2 participants prefer "Coffee"
    And 1 participant prefers "Movies"
    When the AI processes the group preferences
    Then "Dinner" suggestions should have higher compatibility scores
    And "Coffee" should appear in the results
    And suggestions should be ordered by compatibility score

  Scenario: Fallback suggestions when AI fails
    Given all participants have submitted their preferences
    When the AI service encounters an error
    Then fallback activity suggestions should be provided
    And the event status should still be "ready"
    And users should see at least 3 activity options

  Scenario: View AI suggestions as organizer
    Given the AI has generated suggestions for the event
    When the organizer views the results
    Then they should see all suggested activities
    And each activity should show compatibility percentage
    And activities should include images and descriptions

  Scenario: View AI suggestions as participant
    Given the AI has generated suggestions for the event
    And I am a participant in the event
    When I view the event results
    Then I should see all suggested activities
    And I should see all participants' preferences

  Scenario: AI considers diverse activity types
    Given participants suggest different activity types:
      | Outdoor  |
      | Dining   |
      | Cultural |
      | Social   |
    When the AI processes the preferences
    Then the suggestions should include variety
    And at least 2 different activity types should be represented

  Scenario: Cannot view results before all preferences submitted
    Given only 2 out of 4 participants have submitted preferences
    When I try to view the event results
    Then the event status should be "collecting"
    And no AI suggestions should be available yet

  Scenario: AI service processes preferences with stubbed client
    Given an event "AI Coverage" exists organized by "Alice"
    And the following friends are invited:
      | Bob |
    And the organizer "Alice" has submitted preferences:
      | available_times   | Friday 6:00 PM |
      | activities        | Dinner         |
      | budget_min        | 20             |
      | budget_max        | 60             |
      | ideas             | Prefer indoors |
      | location_latitude | 40.7128        |
      | location_longitude| -74.0060       |
    And "Bob" has submitted preferences:
      | available_times | Friday 7:00 PM |
      | activities      | Drinks         |
      | budget_min      | 15             |
      | budget_max      | 50             |
      | ideas           | Somewhere new  |
    And user "Bob" has location coordinates:
      | latitude  | 34.0522 |
      | longitude | -118.2437 |
    And the AI client returns a valid JSON response
    When I run the AI group match service
    Then the AI service should return structured matches

  Scenario: AI service falls back on invalid JSON
    Given an event "AI Coverage" exists organized by "Alice"
    And the organizer "Alice" has submitted preferences:
      | available_times | Saturday 3:00 PM |
      | activities      | Picnic           |
      | budget_min      | 10               |
      | budget_max      | 30               |
      | ideas           | Bring blankets   |
    And the AI client returns an invalid JSON response
    When I run the AI group match service
    Then the AI service should fall back to default matches

  Scenario: AI service falls back when no preferences exist
    Given an event "Empty Event" exists organized by "Alice"
    And no preferences have been submitted for the event
    When I run the AI group match service
    Then the AI service should fall back to default matches
