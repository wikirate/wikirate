@javascript
Feature: company feature
  As user I can use the company page to get information about a company.

  Background:
    Given I go to card "Death Star"

  Scenario: Browse through tabs
    Then I should see "disturbances in the Force"
    Then I click "Datasets" within ".nav-tabs"
    And I should see "Evil Dataset"
    Then I click "Sources" within ".nav-tabs"
    And I should see "thereaderwiki.com"
    Then I click on "Details"
    And I should see "Wikipedia"
    And I wait for ajax response
    Then I should see "space station"

  Scenario: Filter by metric
    When I click on "All Filters"
    And I wait for ajax response
    And I click on "Metric Name" in the offcanvas
    And I fill in "filter[metric_name]" with "deadliness"
    And I close the offcanvas
    And I wait for ajax response
    Then I should not see "disturbances in the Force"
    And I should see "deadliness"

  Scenario: Filter by topic
    When I click on "All Filters"
    And I wait for ajax response

    # When I click on "Metric" in the offcanvas
    And I click on "Topic"
    And I select2 "Wikirate ESG Topics+Environment" from "filter[topic][]"
    And I close the offcanvas
    And I wait for ajax response
    Then I should not see "dinosaurlabor"
    And I should see "disturbances in the Force"

  Scenario: Filter by year
    When I click on "All Filters"
    And I wait for ajax response

    And I click on "Year" in the offcanvas
    And I click on "show more"
    And I check "2001"
    And I close the offcanvas
    And I wait for ajax response
    Then I should not see "dinosaurlabor"
    And I should see "disturbances in the Force"

  # FIXME: Following scenario is useful but fails sporadically, presumably
  # because of slow response.

  # Scenario: Search for not researched values
  #   And I select2 "Not Researched" from "filter[status]"
  #   And I wait 2 seconds
  #   And I wait for ajax response
  #   And I click to sort table by "metric_name"
  #   And I wait 2 seconds
  #   And I wait for ajax response
  #   Then I should not see "disturbances in the Force"
  #   And I should see "BSR Member"
  #   When I click on "2"
  #   Then I should see "Weapons"

  Scenario: Paging
    When I click on "All Filters"
    And I wait for ajax response

    And I click on "Year" in the offcanvas
    And I check "Latest"
    And I close the offcanvas
    Then I should see "Victims by Employees"
    Then I click "2" within ".paging"
    And I should not see "Victims by Employees"
