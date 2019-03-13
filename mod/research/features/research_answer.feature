@javascript
Feature: Research answer
  As signed in user I want to be able to add a new metric answer.

  Background:
    Given I am signed in as Joe User
    And I research
      | metric      | company    | year |
      | Joe User+RM | Apple Inc. | 2009 |

  Scenario: Create an answer
    When I cite source
    And I fill in "9" for "Answer"
    And I fill in "Baam!" for " Comment"
    And I press "Submit"
    Then I should see "2009"
    And I should see "9"
    And I should see "updated less than a minute ago by Joe User"
    And I should see "www.wikiwand.com"
    And I should see "Baam!"
    When I open the year list
    Then I should see "9"

  Scenario: Create an answer and request check
    When I cite source
    And I fill in "10" for "Answer"
    And I fill in "Baam!" for " Comment"
    And I check "request"
    And I press "Submit"
    And I wait for ajax response
    Then I should see "2009"
    And I should see "10"
    And I wait a sec
    And I should see a "comment" icon with tooltip "Has comments"
    And I should see a "check request" icon with tooltip "check requested"
    Then I should see "www.wikiwand.com"
    And I should see "Baam!"
    And I should see "check requested by Joe User"

  Scenario: Create an answer with duplicated source
    When I cite source "Star_Wars"
    And I fill in "10" for "Answer"
    And I fill in "Baam!" for " Comment"
    And I press "Submit"
    Then I should see "2009"
    And I should see "10"
    Then I should see "www.wikiwand.com"
    And I should see "Baam!"


