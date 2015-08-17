@javascript
Feature: Claim
   As signed in user I want to be able to create a new metric and add a value.

  Background:
    Given I am signed in as Joe User

  Scenario: Creating a new metric and adding a value
    When I go to  "/new metric"
    And I fill in "card_name" with "Jedi+size"
    And I press "Submit"
    And In the main card content I click "Add new value"
    And I solocomplete "Death Star" within "form > fieldset.editor > .RIGHT-company"
    And I solocomplete "2015" within "form > fieldset.editor > .RIGHT-year"
    And I fill in "card_subcards__value_content" with "101"
    And I fill in "card_subcards__Link_content" with "http://example.com"
    And I press "Submit"
    And I press "Close"
    # FIXME the new metric should appear witout reloading the page
    And I go to card "Jedi+size"
    Then I should see "Death Star"
    When I go to card "Death Star"
    Then I should see "101"
