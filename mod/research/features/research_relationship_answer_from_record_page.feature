@javascript
Feature: Research relationship answer from record page
  As signed in user I want to be able to add a metric value when I'm on a record page.

  Background:
    Given I am signed in as Joe User
    # And I wait for ajax response
    And I go to card "Jedi+more evil+Death Star"

  Scenario: Adding a metric value with a link source
    When In the main card content I click "Research answer"
    And I select year "2015"
    And I fill in autocomplete "card_subcards__related_company_content" with "Monster Inc"
    And I choose "yes"
    And I cite source
    And I click on "Submit"
    Then I should see "1 related companies"
    # When I click the drop down button for "2015"
    Then I should see "Monster Inc"
