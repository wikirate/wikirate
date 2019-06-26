@javascript
Feature: company feature
  As user I can use the company page to get information about a company.

  Background:
    Given I go to card "Death Star"

  Scenario: Browse through tabs
    Then I should see "disturbances in the Force"
    And I should see "Wikipedia"
    And I wait for ajax response
    Then I should see "fictional mobile space station"
    Then I click on "Topics"
    And I should see "Force"
    Then I click on "Projects"
    And I should see "Evil Project"
    And I should see "2 1"
    Then I click on "Sources"
    And I should see "www.wikiwand.com"
    And I should see "Original"

  Scenario: Filter by metric
    When I click on "More Filters"
    And I click on "Metric"
    And I wait for ajax response
    And I fill in "filter[metric_name]" with "Jedi+deadliness"
    # To change focus
    And I click on "More Filters"
    And I wait for ajax response
    Then I should not see "disturbances in the Force"
    And I should see "deadliness"

  Scenario: Filter by topic
    When I click on "More Filters"
    And I click on "Topic"
    And I wait for ajax response
    And I wait 2 seconds
    And I select2 "Force" from "filter[wikirate_topic][]"
    # To change focus
    And I click on "More Filters"
    And I wait for ajax response
    Then I should not see "dinosaurlabor"
    And I should see "disturbances in the Force"

  Scenario: Filter by year
    And I select2 "2001" from "filter[year]"
    And I wait for ajax response
    Then I should not see "dinosaurlabor"
    And I should see "disturbances in the Force"

  Scenario: Search for not researched values
    And I select2 "Not Researched" from "filter[status]"
    And I wait for ajax response
    And I wait a sec
    And I click to sort table by "metric_name"
    And I wait a sec
    And I wait for ajax response
    Then I should not see "disturbances in the Force"
    And I should see "BSR Member"
    When I click on "2"
    Then I should see "Weapons"

  Scenario: Paging
    Then I should see "Victims by Employees"
    And I should not see "deadliness Research | community assessed"
    Then I click on "2"
    Then I should see "deadliness Research | community assessed"
    And I should not see "Victims by Employees"

