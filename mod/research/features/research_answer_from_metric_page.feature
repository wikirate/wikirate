@javascript
Feature: Research answer from metric page
  As signed in user I want to be able to add a metric value on metric page.

  Background:
    Given I am signed in as Joe User
    And I wait for ajax response
    And I go to card "Jedi+disturbances in the Force"
#     And I maximize the browser

  Scenario: Adding a answer from record details on metric page
   # When I go to card "Jedi+disturbances in the Force"
    And I click on item "Death Star"
    And I click "Research" within ".record-buttons"
    And I wait for ajax response
    And I select year "2015"
    And I choose "yes"
    And I cite source
    And I click on "Submit"
    Then I should see "disturbances in the Force"
    And I should see "yes"
