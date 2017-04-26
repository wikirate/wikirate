@javascript
Feature: create metrics
  A user can create new metrics

  Background:
    Given I am signed in as Joe Camel

  Scenario:  Creating a researched metric
    When I go to new metric
    # And I click "Researched"
    And I fill in "Metric Title" with "MyResearch"
    # And I fill in "Question" with "my question"
    And I choose "Number"
    And I press "Submit"
    Then I should see "Metric Creator"
    And I should see "Awarded for adding your first metric."

