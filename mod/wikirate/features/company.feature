@javascript
Feature: company feature
  As user I can use the company page to get information about a company.

  Background:
    Given I go to card "Death Star"

  Scenario: Browse through tabs
    Then I should see "disturbances in the Force"
    And I should see "Wikipedia"
    And I wait for ajax response
    Then I should see "a number of fictional mobile space stations"
    Then I click on "Topics"
    And I should see "Force"
    Then I click on "Projects"
    And I should see "Evil Project"
    And I should see "3 Companies 2 Metrics"
    Then I click on "Sources"
    And I should see "www.wikiwand.com"
    And I should see "Visit Original"

  Scenario: Filter by metric
    When I click on "Add filter"
    And I click on "Metric"
    And I wait for ajax response
    And I fill in "filter[metric]" with "Jedi+deadliness"
    # To change focus
    And I click on "Add filter"
    And I wait for ajax response
    Then I should not see "disturbances in the Force"
    And I should see "deadliness"

  Scenario: Filter by topic
    When I click on "Add filter"
    And I click on "Topic"
    And I wait for ajax response
    And I select2 "Force" from "filter[wikirate_topic][]"
    # To change focus
    And I click on "Add filter"
    And I wait for ajax response
    Then I should not see "dinosaurlabor"
    And I should see "disturbances in the Force"

  Scenario: Filter by year
    And I select2 "2001" from "filter[year]"
    And I wait for ajax response
    Then I should not see "dinosaurlabor"
    And I should see "disturbances in the Force"

  Scenario: Search for not researched values
    And I select2 "Not Researched" from "filter[metric_value]"
    And I wait for ajax response
    Then I should not see "disturbances in the Force"
    And I should see "BSR Member"
    When I click on "2"
    Then I should see "Weapons"

  Scenario: Paging
    Then I should not see "deadliness"
    Then I click on "2"
    Then I should see "deadliness"
    And I should not see "disturbances in the Force"

