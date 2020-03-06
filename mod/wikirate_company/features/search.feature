@javascript
Feature: search feature
  As user I can search and use paging to browse through search results

  Scenario: quick search
    Given I go to the homepage
    And I search for "Jedi rating" using the navbox
    Then I should see "darkness rating"
    #    When I click on "2"
    #    Then I should see "deadliness"
