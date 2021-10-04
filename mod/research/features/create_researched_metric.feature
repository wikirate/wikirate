@javascript
Feature: create researched metrics
  A user can create new researched metrics

  Background:
    Given I am signed in as Joe Camel

  Scenario: Creating a researched metric
    When I go to new metric
    # And I choose "Number"
    And I fill in "Metric Title" with "MyResearch"
    And I press "Submit"
    Then I should see "MyResearch"
    Then I should see "Metric Creator"
    And I should see "Awarded for adding your first metric."

  Scenario: Creating a relationship metric
    When I go to new metric
    And I click on "Relationship"
    And I choose "Number"
    And I fill in "Metric Title" with "owner of"
    And I fill in "Inverse Title" with "owned by"
    And I scroll 500 pixels down
    And I press "Submit"

    Then I should see "owner of"
    And I should see "Designed by Joe Camel"
    And I should see "Metric Type Relationship"
    And I should see "Value Type Number"
    # And I should see "Metric Creator"
    # And I should see "Awarded for adding your first metric."
