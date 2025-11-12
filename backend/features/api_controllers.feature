Feature: API Controllers Coverage
  As a test suite
  I want to exercise API endpoints through HTTP requests
  So that controllers are properly covered by Cucumber tests

  Background:
    Given the database is clean

  Scenario: Create session via POST /api/session
    When I POST to "/api/session" with JSON:
      """
      {
        "name": "Alice Smith"
      }
      """
    Then the response status should be 200
    And the JSON response should have "user.id"
    And the JSON response should have "user.name" with value "Alice Smith"
    And a user "Alice Smith" should exist in the database


  Scenario: Fetch events list via GET /api/events
    Given I have a session as "Alice"
    And I have created 2 events
    When I GET "/api/events"
    Then the response status should be 200
    And the JSON response should have "events" as an array

  Scenario: Fetch user invitations via GET /api/invitations
    Given I have a session as "Alice"
    And "Alice" has been invited to 3 events
    When I GET "/api/invitations"
    Then the response status should be 200
    And the JSON response should have "invitations" as an array

  Scenario: Fetch event details via GET /api/events/:id
    Given I have a session as "Bob"
    And I have an event "Game Night"
    When I GET "/api/events/:event_id"
    Then the response status should be 200
    And the JSON response should have "event.title" with value "Game Night"


  Scenario: Unauthorized access returns 401
    When I POST to "/api/events" with JSON:
      """
      {
        "event": {"title": "Unauthorized Event"}
      }
      """
    Then the response status should be 401

  Scenario: Invalid token returns 404
    When I GET "/api/invitations/invalid-token-999"
    Then the response status should be 404

  Scenario: Event not found returns 404
    Given I have a session as "Helen"
    When I GET "/api/events/99999"
    Then the response status should be 404


