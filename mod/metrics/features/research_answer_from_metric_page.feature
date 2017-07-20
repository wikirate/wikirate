@javascript
Feature: Research answer from metric page
  As signed in user I want to be able to add a metric value on metric page.

  Background:
    Given I am signed in as Joe User
    And I wait for ajax response
    And I go to card "Jedi+disturbances in the Force"
    And I maximize the browser

  Scenario: Adding a metric value with a link source on metric page
    When In the main card content I click "Research answer"
    And I select "Death Star" from "Company"
    And I click on "Next"
    And I click on "Research answer"
    And I wait for ajax response
    And I fill in "2015" for "Year"
    And I fill in "yes" for "Answer"
    And I click on "Add a new source"
    And I fill in "http://example.com" for "URL"
    And I click on "Add and preview"
    Then I should not see "Problems"
    And I should see "Example Domain"
    And I should see "added less than a minute ago"
    And I click on "Cite!"
    And I click on "Submit"
    # FIXME the new metric should appear witout reloading the page
    And I go to card "Jedi+disturbances in the Force"
    Then I should see "Death Star"
    When I go to card "Death Star"
    Then I should see "disturbances in the Force"
    And I should see "yes"

  Scenario: Adding a metric value with a file source on metric page
    When In the main card content I click "Research answer"
    And I select "Death Star" from "Company"
    And I click on "Next"
    And I click on "Research answer"
    And I wait for ajax response
    And I fill in "2015" for "Year"
    And I fill in "yes" for "Answer"
    And I click on "Add a new source"
    And I click on "File"
    And I upload the file "file.txt"
    And I wait for ajax response
    Then I should see "file.txt 9 Bytes"
    And I click on "Add and preview"
    Then I should not see "Problems"
    And I should see "title needed"
    And I should see "added less than a minute ago"
    And I click on "Cite!"
    And I click on "Submit"
    # FIXME the new metric should appear witout reloading the page
    And I go to card "Jedi+disturbances in the Force".
    Then I should see "Death Star"
    When I go to card "Death Star"
    Then I should see "disturbances in the Force"
    And I should see "yes"


  Scenario: Adding a answer from record details on metric page
    When I go to card "Jedi+disturbances in the Force"
    And I click on item "Death Star"
    And I click on "Research answer"
    And I wait for ajax response
    And I fill in "2015" for "Year"
    And I fill in "yes" for "Answer"
    And I click on "Add a new source"
    And I fill in "http://example.com" for "URL"
    And I click on "Add and preview"
    # if window is to small cite is hidden under the iframe
    And I click! on "Cite!"
    And I click on "Submit"
    Then I should see "disturbances in the Force"
    And I should see "yes"
