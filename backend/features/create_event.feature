Feature: Create Event
  As an event organizer
  I want to create a new hangout event
  So that I can invite friends and plan group activities

  Background:
    Given I am a registered user named "Alice"

  Scenario: Successfully create an event with all details
    When I create an event with the following details:
      | title                  | Weekend Brunch          |
      | notes                  | Let's catch up!         |
    And I set my preferences:
      | available_times | Saturday 11:00 AM, Sunday 10:00 AM |
      | activities      | Brunch, Coffee                      |
      | budget_min      | 15                                  |
      | budget_max      | 40                                  |
      | ideas           | Something casual and fun            |
    And I invite the following friends:
      | Bob     |
      | Charlie |
      | Diana   |
    Then the event should be created successfully
    And I should be the organizer
    And my preferences should be saved
    And 3 invitation links should be generated
    And the event status should be "collecting"

  Scenario: Create event with minimal information
    When I create an event with the following details:
      | title | Quick Meetup |
    And I set my preferences:
      | available_times | Saturday 3:00 PM   |
      | activities      | Coffee             |
      | budget_min      | 10                 |
      | budget_max      | 20                 |
    Then the event should be created successfully
    And the event should have a default share token

  Scenario: Create event without title uses default
    When I create an event with the following details:
      | notes | Just hanging out |
    And I set my preferences:
      | available_times | Saturday 3:00 PM |
      | activities      | Coffee           |
      | budget_min      | 5                |
      | budget_max      | 15               |
    Then the event title should be "New Hangout"

  Scenario: Cannot create event without authentication
    Given I am not authenticated
    When I try to create an event
    Then I should receive an unauthorized error

  Scenario: Create event with location preference
    When I create an event with the following details:
      | title | Beach Hangout |
    And I set my preferences:
      | available_times | Saturday 2:00 PM |
      | activities      | Beach, Picnic    |
      | budget_min      | 20               |
      | budget_max      | 50               |
    And I enable location sharing
    Then my location should be saved with my preferences

  Scenario: Invite friends with email addresses
    When I create an event with the following details:
      | title | Tech Meetup |
    And I set my preferences:
      | available_times | Friday 6:00 PM |
      | activities      | Dinner         |
      | budget_min      | 30             |
      | budget_max      | 60             |
    And I invite friends with emails:
      | name  | email             |
      | Bob   | bob@example.com   |
      | Carol | carol@example.com |
    Then invitation emails should include access tokens

