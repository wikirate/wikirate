@javascript
Feature: Edit wikirating
  As signed in user I want to be able to edit a formula of a wikirating

  Background:
    Given I am signed in as Joe User

  Scenario:  Editing formula
    When I edit "Jedi+darkness rating+formula"
    And I click on "add metric"
    And I click on metric "deadliness"
    And I wait for ajax response
    #And I click on "Add this metric"
    #Then I should see "deadliness"
    #And I should see "0"
