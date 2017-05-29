@javascript
Feature: Research answer fail
  As signed in user if I try to add a new answer I should get
  a decent error message if important data is missing.

  Background:
    Given I am signed in as Joe User
    And I go to  "/new metric_value"
    And I wait for ajax response
    And I maximize the browser
    And I select "Apple Inc" from "Company"
    And I select "Joe User+researched" from "Metrics"
    And I click on "Next"
    And I click on "Research answer"
    And I click on "Add a new source"
    And I fill in "http://example.com" for "URL"
    And I press "Add and preview"
    And I wait for ajax response
    And I scroll 200 pixels

  Scenario: Missing year
    When I click on "Cite!"
    And I wait for ajax response
    And I fill in "10" for "Answer"
    And I fill in "Baam!" for "Comment"
    And I press "Submit"
    And I should see "Problems"
    And I should see "YEAR: No year given."

  Scenario: Missing value
    When I click on "Cite!"
    And I fill in "2009" for "Year"
    And I fill in "Baam!" for "Comment"
    And I press "Submit"
    And I should see "Problems"
    And I should see "ANSWER: No answer given."

  Scenario: Missing source
    When I fill in "2009" for "Year"
    And I fill in "10" for "Answer"
    And I fill in "Baam!" for "Comment"
    And I press "Submit"
    And I should see "Problems"
    And I should see "SOURCE: no source cited"
