@javascript
Feature: edit metrics
  A user can edit metrics

  Background:
    Given I am signed in as Joe Camel

Scenario: Creating a researched metric
  I go to a metric page
  And the metric value type is Number
  And I don’t see “Options”
  And I see Unit
  And I click to edit the value type
  And I choose Category
  And I click save
  Then I should see Options
  And I should not see Unit