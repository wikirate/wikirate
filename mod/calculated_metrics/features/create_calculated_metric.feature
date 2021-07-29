@javascript
Feature: create calculated metrics
  A user can create new calculated metrics

  Background:
    Given I am signed in as Joe Camel

  Scenario: Creating a formula metric
    When I go to new metric
    And I click on "Calculated"
    And I fill in "Metric Title" with "MyFormula"
    #And I fill in "Question" with "my question"
    # And I fill in "Topic" with "Animal Welfare"
    And I select "Animal Welfare" from "Topic"
    And I scroll 500 pixels down
    And I press "Submit"
    Then I should see "MyFormula"
    And I should see "Designed by Joe Camel"
    And I should see "Metric Type Formula"
    And I should see "Metric Creator"
    And I should see "Awarded for adding your first metric."

  Scenario: Creating a score metric
    When I go to new metric
    And I click on "Calculated"
    And I click on "Score"
    And I select2 "Jedi+Victims by Employees" from "pointer_select"
    And I wait a sec
    # And I fill in "Topic" with "Animal Welfare"
    And I press "Submit"
    Then I should see "Victims by Employees"
    And I should see "Metric Type Score"
    And I should see "Scored by Joe Camel"
    And I should see "Metric Creator"
    And I should see "Awarded for adding your first metric."

  Scenario: Creating a score metric fails
    When I go to new metric
    And I click on "Calculated"
    And I click on "Score"
    And I select2 "Jedi+deadliness" from "pointer_select"
    And I wait a sec
    And I press "Submit"
    And I should see "NAME: must be unique;"
    And I should see "'Jedi+deadliness+Joe Camel' already exists."

  Scenario: Creating a WikiRating
    When I go to new metric
    And I click on "Calculated"
    And I click on "WikiRating"
    And I fill in "Metric Title" with "MyWikiRating"
    # And I fill in "Topic" with "Animal Welfare"
    And I press "Submit"
    Then I should see "MyWikiRating"
    And I should see "Designed by Joe Camel"
    And I should see "Metric Type WikiRating"
    And I should see "Metric Creator"
    And I should see "Awarded for adding your first metric."
