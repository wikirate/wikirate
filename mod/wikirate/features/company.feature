@javascript
Feature: company feature
  As user I can use the company page to get information about a company.

  Background:
    Given I go to card "Death Star"

  Scenario: Browse through tabs
    Then I should see "disturbances in the Force"
    And I should see "Wikipedia"
    And I wait for ajax response
    Then I should see "A number of fictional mobile space stations"
    Then I click on "Topics"
    And I should see "Force"
    Then I click on "Projects"
    And I should see "Evil Project"
    And I should see "3 Companies, 2 Metrics"
    Then I click on "Sources"
    And I should see "www.wikiwand.com"
    And I should see "Visit Original"

  Scenario: Filter by metric
    When I click on "more filter options"
    And I wait for ajax response
    And I fill in "Metric" with "Jedi+deadliness"
    And I submit form
    Then I should not see "disturbances in the Force"
    And I should see "deadliness"

  Scenario: Filter by topic
    When I click on "more filter options"
    And I wait for ajax response
    And I fill in "Topic" with "Force"
    And I submit form
    Then I should not see "dinosaurlabor"
    And I should see "disturbances in the Force"

  Scenario: Filter by year
    And I select "2001" from "Year"
    And I submit form
    Then I should not see "dinosaurlabor"
    And I should see "disturbances in the Force"

  Scenario: Search for not researched values
    And I select "Not Researched" from "Value"
    And I submit form
    Then I should not see "disturbances in the Force"
    And I should see "Weapons"

  Scenario: Paging
    Then I should not see "deadliness"
    Then I click on "2"
    Then I should see "deadliness"
    And I should not see "disturbances in the Force"

