@javascript
Feature: Double check
  As signed in user I can double check and request checks for metric values

Background:
  Given I am signed in as Joe User

Scenario: Double check source
  When I go to card "Jedi+disturbances in the Force+Death Star+2000"
  Then I should see "Double check"
  When I click on "Double check"
  Then I should see "Yes, I checked"
  When I click on icon "times-circle"
  Then I should see "Double check"

  Scenario: Request double check
    When edit "Jedi+disturbances in the Force+Death Star+2000"
    And I check "Request that another researcher double checks this value"
    And I submit
    Then I should see "Double check requested by Joe User"
    When I click on "Double check requested by Joe User"
  Then I should see "I double checked"
    When I click on icon "times-circle"
    Then I should see "Double check requested by Joe User"
    When I click on "edit"
    And I uncheck  "Request that another researcher double checks this value"
    And I submit
    Then I should see "Double check"
    And I should not see "requested by Joe User"
