@javascript
Feature: Research answer fail
  As signed in user if I try to add a new answer I should get
  a decent error message if important data is missing.

  Background:
    Given I am signed in as Joe User
    And I go to  "/new metric_value"
    And I fill in autocomplete "metric" with "Joe User+researched"
    And I fill in autocomplete "wikirate_company" with "Apple Inc."
    And I select year "2009"

  Scenario: Missing value
    And I fill in "http://example.com" for "URL"
    And I press "Add"
    When I click on "Cite!"
    And I fill in "Baam!" for "Comment"
    And I press "Submit"
    And I should see "Problems"
    And I should see "VALUE: Only numeric content is valid for this metric."

  Scenario: Missing source
    And I fill in "10" for "Answer"
    And I fill in "Baam!" for "Comment"
    And I press "Submit"
    And I should see "Problems"
    And I should see "SOURCE: no source cited"
