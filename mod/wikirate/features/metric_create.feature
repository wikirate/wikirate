Feature: create metrics
  A user can create new metrics

  Background:
    Given I am signed in as Joe User

  Scenario:  Creating a researched metric
    When I go to new metric
    And I choose "Researched"
    And I fill in "Metric Title" with "MyResearch"
    And I fill in "Question" with "my question"
    And I fill in "Value Type" with "Number"
    And I press "Submit"
