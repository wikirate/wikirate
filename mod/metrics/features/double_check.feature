@javascript
Feature: Double check
  As signed in user I can double check and request checks for metric values

Background:
  Given I am signed in as Joe User

Scenario: Double check source
  When I go to "Jedi+disturbances in the Force+Death Star+2000"
  Then I should see "Double check"
  When I click on "Double check"
  Then I should see "I double checked"

  And I select "Apple Inc" from "Company"
  And I select "Joe User+researched" from "Metrics"
  And I click on "Next"
  And I click on "Add answer"
  And I click on "Add a new source"