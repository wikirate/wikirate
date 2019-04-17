@javascript
Feature: Research answer for hybrid metric
  As signed in user I want to be able to research answers for a hybrid metric

  Background:
    Given I am signed in as Joe User

  Scenario: Override a calculated answer
    When I go to card "Jedi+deadlier+Slate Rock and Gravel Company+2004"
    Then I should see "1,003"
    When I edit answer
    And I fill in "50" for "Answer"
    And I cite source
    And I press "Save"
    Then I should not see "Problem"
    And I should see "50"
    And I should see "updated"

  Scenario: Create a new researched answer
    When I go to card "Jedi+deadlier"
    Then I should see "Slate Rock and Gravel Company"
    And I should see "1,003"
    And I should not see "Research answer"
    When I click on item "Slate Rock and Gravel Company"
    And I click on "Research answer"
    And I select year "2014"
    And I cite source
    And I fill in "25" for "Answer"
    And I press "Submit"
    Then I should see "2014"
    And I should see "25"
    And I should see "updated less than a minute ago by Joe User"
    And I should see "www.wikiwand.com"
