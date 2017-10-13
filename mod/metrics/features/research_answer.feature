@javascript
Feature: Research answer
  As signed in user I want to be able to add a new metric answer.

  Background:
    Given I am signed in as Joe User
    And I go to  "/new metric_value"
    And I wait for ajax response
#     And I maximize the browser
    And I select "Apple Inc" from "Company"
    And I select "Joe User+researched" from "Metrics"
    And I click on "Next"
    And I click on "Research answer"
    And I wait 10 seconds
    And I wait for ajax response
    And I click on "Add a new source"

  Scenario: Create a metric value
    When I fill in "http://example.com" for "URL"
    And I press "Add and preview"
    And I wait for ajax response
    And I scroll 200 pixels
    And I click on "Cite!"
    And I fill in "2009" for "Year"
    And I fill in "10" for "Answer"
    And I fill in "Baam!" for "Comment"
    And I press "Submit"
    And I wait for ajax response
    And I scroll -10000 pixels
    Then I should see "2009"
    And I should see "10"
    And I should see a "comment" icon
    And I click the drop down button for "2009"
    Then I should see "example.com"
    And I should see "Baam!"
    And I scroll 10000 pixels
    And I should see "Research Answer"

  Scenario: Create a metric value and request check
    When I fill in "http://example.com" for "URL"
    And I press "Add and preview"
    And I wait for ajax response
    And I scroll 200 pixels
    And I click on "Cite!"
    And I fill in "2009" for "Year"
    And I fill in "10" for "Answer"
    And I fill in "Baam!" for "Comment"
    And I check "Request that another researcher double check this value"
    And I press "Submit"
    And I wait for ajax response
    And I scroll -10000 pixels
    Then I should see "2009"
    And I should see "10"
    And I should see a "comment" icon with tooltip "Has comments"
    And I should see a "check request" icon with tooltip "check requested"
    And I click the drop down button for "2009"
    Then I should see "example.com"
    And I should see "Baam!"
    And I should see "check requested by Joe User"
    And I should see "Research Answer"

  Scenario: Create a metric value with duplicated source
    When I fill in "http://www.wikiwand.com/en/Star_Wars" for "URL"
    And I press "Add and preview"
    And I wait for ajax response
    And I scroll 200 pixels
    And I click on "Cite!"
    And I fill in "2009" for "Year"
    And I fill in "10" for "Answer"
    And I fill in "Baam!" for "Comment"
    And I press "Submit"
    And I wait for ajax response
    And I scroll -10000 pixels
    Then I should see "2009"
    And I should see "10"
    And I should see a "comment" icon
    And I click the drop down button for "2009"
    Then I should see "www.wikiwand.com"
    And I should see "Baam!"


