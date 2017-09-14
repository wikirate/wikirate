@javascript
Feature: Unknown value
  As signed in user I can mark a value as unknown

  Background:
    Given I am signed in as Joe User

  Scenario: Mark answer as unknown
    When I go to card "Jedi+disturbances in the Force+Death Star+2000"
    Then I should see "yes"
    When I edit "Jedi+disturbances in the Force+Death Star+2000"
    And I fill in "" for "Answer"
    And I check "Unknown"
    And I submit
    Then I should see "Unknown"
    And I should not see "Yes"

  Scenario: "Unknown" overrides other value change
    When I edit "Jedi+disturbances in the Force+Death Star+2000"
    And I check "Unknown"
    And I fill in "no" for "Answer"
    And I submit
    Then I should see "Unknown"
