Feature: AI Activity Suggestions Job Processing
  As the system
  I want to automatically generate activity suggestions when all preferences are submitted
  So that participants can vote on AI-matched activities

  Background:
    Given the database is clean

  Scenario: Job handles event not found gracefully
    When the GenerateActivitySuggestionsJob runs for non-existent event 99999
    Then the job should complete without error
    And no activity suggestions should be created

  Scenario: Job skips already-ready events
    Given "Alice" creates an event "Movie Night"
    And "Bob" is invited
    And all participants have submitted their preferences
    And the event is already marked as "ready"
    When the GenerateActivitySuggestionsJob runs for the event
    Then the job should complete without creating duplicate suggestions

  Scenario: Job handles AI service errors gracefully
    Given "Alice" creates an event "Beach Day"
    And "Bob" is invited
    And all participants submit their preferences
    And the AI service will return an error
    When the job is processed
    Then the job should complete without crashing
    And the error should be logged

  Scenario: Job handles empty AI response
    Given "Alice" creates an event "Park Picnic"
    And "Bob" is invited  
    And all participants submit their preferences
    And the AI service will return empty matches
    When the job is processed
    Then the event should not be marked as ready
    And no activity suggestions should be created

  Scenario: Job regenerates suggestions and clears previous votes
    Given "Alice" creates an event "City Tour"
    And "Bob" and "Charlie" are invited
    And all participants submit their preferences
    And the event currently has stored votes
    And the AI service will return sample matches
    When the job is processed
    Then AI-generated activity suggestions should exist
    And previous votes should be cleared

