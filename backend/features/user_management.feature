Feature: User Management
  As a user
  I want to manage my profile and account
  So that I can personalize my experience and be recognized in events

  Scenario: Create a new user account
    When I create an account with name "Alice"
    Then my account should be created successfully
    And I should have a unique user ID

  Scenario: Update user profile
    Given I am a registered user named "Alice"
    When I update my name to "Alice Johnson"
    Then my name should be updated
    And my invitations should reflect the new name

  Scenario: Enable location sharing
    Given I am a registered user named "Alice"
    When I enable location permissions
    And I set my location to coordinates:
      | latitude  | 40.7128 |
      | longitude | -74.006 |
    Then my location should be saved
    And location permission should be enabled

  Scenario: Disable location sharing
    Given I am a registered user with location enabled
    When I disable location permissions
    Then my location should be cleared
    And location permission should be disabled

  Scenario: Update location via API
    Given I am a registered user named "Alice"
    When I PATCH "/api/users/:user_id" with JSON:
      """
      {
        "user": {
          "location_permission": true,
          "location_latitude": 40.7128,
          "location_longitude": -74.0060
        }
      }
      """
    Then the response status should be 200
    And my location should be saved
    And location permission should be enabled
    When I PATCH "/api/users/:user_id" with JSON:
      """
      {
        "user": {
          "location_permission": false
        }
      }
      """
    Then the response status should be 200
    And my location should be cleared
    And location permission should be disabled

  Scenario: Claim pending invitations
    Given I am invited to 3 events as "Alice"
    When I create an account with name "Alice"
    Then all 3 invitations should be linked to my account
    And I should be able to access those events

  Scenario: Case-insensitive invitation matching
    Given I am invited to an event as "alice"
    When I create an account with name "Alice"
    Then the invitation should be linked to my account

  Scenario: User name uniqueness
    Given a user "Alice" already exists
    When I try to create an account with name "Alice"
    Then I should see an error about duplicate name
    And the account should not be created

  Scenario: User name normalization
    When I create an account with name "  Bob   Smith  "
    Then my name should be saved as "Bob Smith"
    And extra whitespace should be removed

  Scenario: View user profile
    Given I am a registered user named "Alice"
    And I have organized 2 events
    And I am invited to 3 events
    When I view my profile
    Then I should see my name
    And I should see my event count
    And I should see my location settings

  Scenario: User without location
    Given I am a registered user named "Alice"
    And I have not enabled location
    When I view my profile API response
    Then the location field should be null
    And location_permission should be false
