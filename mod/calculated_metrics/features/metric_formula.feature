@javascript
Feature: Edit metric formulas
  As signed in user I want to be able to edit formulas of calculated metrics

  Background:
    Given I am signed in as Joe User

  Scenario: Editing a Formula card's formula
    When I edit "Jedi+friendliness+formula"
    And I click on "add metric"
    And I click on "Add filter"
    And I click on "Keyword"
    And I fill in "filter[name]" with "multi"

    # these two are just to trigger the filter
    When I click on "Add filter"
    And I wait for ajax response

    Then I should see "small multi"
    And I should see "big multi"
    And I check "Joe User+big multi"
    And I click on "Add Selected"
    Then I should see "M0"
    And I should see "M1"
