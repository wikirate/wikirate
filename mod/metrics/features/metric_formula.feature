@javascript
Feature: Edit metric formulas
  As signed in user I want to be able to edit formulas of calculated metrics

  Background:
    Given I am signed in as Joe User

  Scenario: Editing a WikiRating formula
    When I edit "Jedi+darkness rating+formula"
    And I click on "add metric"
    And I check "Jedi+deadliness+Joe Camel"
    And I click on "Add Selected"
    And I wait for ajax response
    Then I should see "Joe Camel"
    And I should see "0"
    And the weight total should be "100"
    And the submit button should be disabled
    And I set weight for "Jedi+deadliness+Joe Camel" to "30"
    Then the weight total should be "130"
    And the submit button should be disabled
    And I set weight for "Jedi+deadliness+Joe User" to "30"
    Then the weight total should be "100"
    And the submit button should not be disabled
    And I click on "Submit"
    And I should see "30"
    And I should see "40"
    And I should see "WikiRating"
    And I should not see "100"

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
