@javascript
Feature: Claim
   I want be able to create a new metric and add a value.

  Background:
    Given I am signed in as Joe User

  Scenario: Creating a new metric and adding a value
    When I go to  "/new metric"
    And I fill in "card_name" with "Jedi+size"
    And I press "Submit"
    And In the main card content I click "Add new value"
    And I wait until ajax response
    And I print html of the page
    And I select option "Death Star" from "form > fieldset.editor > .RIGHT-company select"
    #And I select "2015" from "pointer_select" within ".card-editor.RIGHT-year"
    And I fill in "card_subcards__value_content" with "100"
    And I fill in "card_subcards__Link_content" with "htpp://example.com"
    And I press "Submit"
    And I wait 20 seconds
    Then I should see "Death Star"
  #
  # Scenario: Adding a new value
  #   When I go to "/new source"
  #   And I fill in "card_subcards__Link_content" with "http://example.com"
  #   And I press "Submit"
  #   And I go to  "/new claim"
  #   And I fill in "card_name" with "Hello World is a name of a new born baby"
  #   And I wait until ajax response
  #   And I fill in "sourcebox" with "http://example.com"
  #   And I press "Add" within ".sourcebox"
  #   And I wait until ajax response
  #   And I press "Submit"
  #   And I wait until ajax response
  #   Then I should not see "Problems with"
  #   And the card "Hello World is a name of a new born baby" should contain "example.com"
  #
  # Scenario: Creating a claim with a existing source card's url
  #   When I go to "/new source"
  #   And I fill in "card_subcards__Link_content" with "http://example.com"
  #   And I press "Submit"
  #   And I go to  "/new claim"
  #   And I fill in "card_name" with "Hello World is a name of a new born baby"
  #   And I wait until ajax response
  #   And I fill in "sourcebox" with card path of source with link "http://example.com"
  #   And I press "Add" within ".sourcebox"
  #   And I wait until ajax response
  #   And I press "Submit"
  #   And I wait until ajax response
  #   Then I should not see "Problems with"
  #   And the card "Hello World is a name of a new born baby" should contain "example.com"
  #
  # Scenario: Creating a claim with a source without pressing add
  #   When I go to  "/new claim"
  #   And I fill in "card_name" with "Hello World is a name of a new born baby"
  #   And I wait until ajax response
  #   And I fill in "sourcebox" with "http://google.com/?q=ymca"
  #   And I press "Submit"
  #   And I wait until ajax response
  #   Then I should not see "Problems with"
  #   And the card "Hello World is a name of a new born baby" should contain "google.com"
  #
  # Scenario: Claim name counting is correct
  #   When I go to  "/new claim"
  #   And I fill in "card_name" with "Hello World is a name of a new born baby"
  #   And I wait until ajax response
  #   Then I should see "60 character(s) left"