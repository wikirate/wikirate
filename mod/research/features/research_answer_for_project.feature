@javascript
Feature: Research answer for project
  Keep the flow

  Background:
    Given I am signed in as Joe User
    And I go to card "Evil Project"

  Scenario: Use the next button
    When I click on "Research"
    Then I should see "Evil Project"
    And I should see "disturbances in the Force"
    And I should see "Death Star"

    When I select year "2017"
    And I cite source

    And I choose "yes"
    And I press "Submit"
    Then I should see "Success! To research another answer select a different metric or year."

    When I click the next button
    Then I should see "researched number 2"
    And I should see "Death Star"
    And I should see "2017"

