Feature: Event Voting
  As a participant in an event
  I want to vote on suggested activities
  So that the group can choose the best option together

  Background:
    Given the database is clean

  Scenario: Participants vote on AI-suggested activities
    Given "Alice" has organized an event "Weekend Fun"
    And "Bob" and "Charlie" are invited to the event
    And all participants have submitted their preferences
    And AI has generated activity suggestions
    When "Bob" votes on the suggestions with scores:
      | match_id | score |
      | match_1  | 5     |
      | match_2  | 3     |
      | match_3  | 4     |
    Then Bob should see his votes recorded
    And the event should have voting data

  Scenario: Multiple participants vote and see aggregated results
    Given "Alice" has organized an event "Dinner Plans"
    And "Bob" and "Charlie" are invited to the event
    And all participants have submitted their preferences
    And AI has generated activity suggestions
    When "Bob" votes on the suggestions with scores:
      | match_id | score |
      | match_1  | 5     |
      | match_2  | 3     |
    And "Charlie" votes on the suggestions with scores:
      | match_id | score |
      | match_1  | 4     |
      | match_2  | 5     |
    Then the votes summary should show combined scores
    And match_1 should have total score of 9
    And match_2 should have total score of 8

  Scenario: Participant updates their vote
    Given "Alice" has organized an event "Movie Night"
    And "Bob" is invited to the event
    And all participants have submitted their preferences
    And AI has generated activity suggestions
    And "Bob" has already voted on match_1 with score 3
    When "Bob" votes on the suggestions with scores:
      | match_id | score |
      | match_1  | 5     |
    Then Bob should see his updated vote for match_1 as 5

  Scenario: Cannot vote on event that is not ready
    Given "Alice" has organized an event "Park Day"
    And "Bob" is invited to the event
    And "Bob" has submitted preferences
    When "Bob" attempts to vote on the suggestions
    Then Bob should see an error "Event is not ready for voting"
    And the response status should be 422

  Scenario: Non-participant cannot vote on event
    Given "Alice" has organized an event "Private Party"
    And "Bob" is invited to the event
    And all participants have submitted their preferences
    And AI has generated activity suggestions
    And "Charlie" is a registered user
    When "Charlie" attempts to vote on the event
    Then Charlie should see an error "Forbidden"
    And the response status should be 403

  Scenario: Event completes after everyone votes
    Given "Alice" has organized an event "Final Choice"
    And "Bob" and "Charlie" are invited to the event
    And "Bob" has submitted preferences
    And "Charlie" has submitted preferences
    And AI has generated activity suggestions
    When "Alice" votes on the suggestions with scores:
      | match_id | score |
      | match_1  | 5     |
      | match_2  | 4     |
      | match_3  | 3     |
    And "Bob" votes on the suggestions with scores:
      | match_id | score |
      | match_1  | 5     |
      | match_2  | 4     |
      | match_3  | 3     |
    And "Charlie" votes on the suggestions with scores:
      | match_id | score |
      | match_1  | 5     |
      | match_2  | 4     |
      | match_3  | 3     |
    Then the event should be completed after voting
    And the event final match should be stored
