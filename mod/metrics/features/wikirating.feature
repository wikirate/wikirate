@javascript
Feature: Edit wikirating
  As signed in user I want to be able to edit a formula of a wikirating

  Background:
    Given I am signed in as Joe User

  Scenario:  Editing formula
    When I edit "Jedi+darkness rating+formula"
    And I click on "add metric"
    When I click on "Add filter"
    And I click on "Project"
    And I select "Evil Project" from "filter[project]"
    And I check "Jedi+deadliness+Joe Camel"
    And I click on metric "disturbances in the Force"
    And I wait for ajax response
    And I press "Add this metric"
    Then I should see "deadliness"
    And I should see "0"
