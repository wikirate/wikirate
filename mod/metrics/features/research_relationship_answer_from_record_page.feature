@javascript
Feature: Research relationship answer from record page
  As signed in user I want to be able to add a metric value when I'm on a record page.

  Background:
    Given I am signed in as Joe User
    And I wait for ajax response
    And I go to card "Jedi+more evil+Death Star"
#    And I maximize the browser

  Scenario: Adding a metric value with a link source
    When In the main card content I click "Research answer"
    And I select year "2009"
    And I select year "2015"
    # And I fill in "2015" for "Year"
    And I fill in "Monster Inc" for "Related Company"
    And I fill in "yes" for "Answer"
    And I click on "Add a new source"
    And I fill in "http://example.com" for "URL"
    And I click on "Add and preview"
    Then I should not see "Problems"
    And I should see "Example Domain"
    And I should see "added less than a minute ago"
    And I click on "Cite!"
    And I click on "Submit"
    And I wait for ajax response
    # And I go to card "Jedi+more evil+Death Star"
    Then I should see "1 companies"
    And I should see "2 companies"
    When I click the drop down button for "2015"
    Then I should see "Monster Inc"
