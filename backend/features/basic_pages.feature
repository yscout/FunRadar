Feature: Basic application pages
  As a visitor
  I want to load the main web pages
  So that the UI endpoints stay healthy

  Scenario: Visit the landing page
    When I GET the root path
    Then the response status should be 200
