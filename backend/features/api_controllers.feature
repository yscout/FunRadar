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

  Scenario: Create event via POST /api/events with preferences and invites
    Given I have a session as "Alice"
    When I POST to "/api/events" with JSON:
      """
      {
        "event": {
          "title": "Team Outing",
          "notes": "Let us plan something fun",
          "organizer_preferences": {
            "available_times": ["Friday 6:00 PM"],
            "activities": ["Dinner", "Karaoke"],
            "budget_min": 25,
            "budget_max": 60,
            "ideas": "Prefer something indoors"
          },
          "invites": [
            { "name": "Bob" },
            { "name": "Charlie", "email": "charlie@example.com" }
          ]
        }
      }
      """
    Then the response status should be 201
    And the JSON response should have "event.status" with value "collecting"
    And an event "Team Outing" should exist in the database
    And the event should have 2 participant invitations
    And the organizer preference should be persisted


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

  Scenario: Manage invitation preference via API
    Given I have a session as "Alice"
    And I have an event "Taste Tour"
    And "Bob" is invited with token "pref-token"
    When I POST to "/api/invitations/:invitation_token/preference" with JSON:
      """
      {
        "preference": {
          "available_times": ["Friday 7:00 PM"],
          "activities": ["Dinner", "Drinks"],
          "budget_min": 30,
          "budget_max": 80,
          "ideas": "Some place fancy"
        }
      }
      """
    Then the response status should be 200
    And the JSON response should have "preference.available_times" as an array
    And the invitation status should be "submitted"
    When I GET "/api/invitations/:invitation_token/preference"
    Then the response status should be 200
    And the JSON response should have "preference.activities" as an array
    When I PATCH "/api/invitations/:invitation_token/preference" with JSON:
      """
      {
        "preference": {
          "available_times": ["Saturday 1:00 PM"],
          "activities": ["Brunch"],
          "budget_min": 20,
          "budget_max": 40,
          "ideas": "Something casual"
        }
      }
      """
    Then the response status should be 200
    And the invitation status should be "submitted"

  Scenario: Claim invitation via API
    Given I have a session as "Bob"
    And "Bob" is invited with token "claim-token"
    When I GET "/api/invitations/:invitation_token"
    Then the response status should be 200
    And the JSON response should have "invitation.name" with value "Bob"
    When I PATCH "/api/invitations/:invitation_token" with JSON:
      """
      {
        "invitation": {}
      }
      """
    Then the response status should be 200
    And the invitation should be attached to user "Bob"

  Scenario: View event progress and results via API
    Given I have a session as "Alice"
    And I have an event "Progress Party"
    And for this event 2 participants have submitted preferences
    And AI has generated matches
    When I GET "/api/events/:event_id/progress"
    Then the response status should be 200
    And the JSON response should have "event.progress" as an array
    When I GET "/api/events/:event_id/results"
    Then the response status should be 200
    And the JSON response should have "matches" as an array

  Scenario: Access event via share token without authentication
    Given I have a session as "Alice"
    And I have an event "Shareable Event"
    And I store the event share token
    And I sign out
    When I GET "/api/events/:event_id?share_token=:share_token"
    Then the response status should be 200
    And the JSON response should have "event.title" with value "Shareable Event"
