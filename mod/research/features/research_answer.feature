@javascript
Feature: Research answer
  As signed in user I want to be able to add a new metric answer.

  Background:
    Given I am signed in as Joe User
    And I go to  "/new answer"
    And I fill in autocomplete "metric" with "Joe User+researched"
    And I fill in autocomplete "wikirate_company" with "Apple Inc."
    And I select year "2009"

  Scenario: Create a metric value
    When I cite source
    And I fill in "9" for "Answer"
    And I fill in "Baam!" for " Comment"
    And I press "Submit"
    Then I should see "2009"
    And I should see "9"
    And I should see "updated less than a minute ago by Joe User"
    And I should see "www.wikiwand.com"
    And I should see "Baam!"
    When I click on "2009"
    Then I should see "9"

  Scenario: Create a metric value and request check
    When I cite source
    And I fill in "10" for "Answer"
    And I fill in "Baam!" for " Comment"
    And I check "request"
    And I press "Submit"
    Then I should see "2009"
    And I should see "10"
    And I should see a "comment" icon with tooltip "Has comments"
    And I should see a "check request" icon with tooltip "check requested"
    Then I should see "www.wikiwand.com"
    And I should see "Baam!"
    And I should see "check requested by Joe User"

  Scenario: Create a metric value with duplicated source
    When I cite source "Star_Wars"
    And I fill in "10" for "Answer"
    And I fill in "Baam!" for " Comment"
    And I press "Submit"
    Then I should see "2009"
    And I should see "10"
    Then I should see "www.wikiwand.com"
    And I should see "Baam!"


