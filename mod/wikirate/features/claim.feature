@javascript
Feature: Claim
  In order to have a short sourced statement about a Company and a Topic
  As a User
  I want to create and read claims

  Background:
    Given I am signed in as Joe User

  Scenario: Creating a claim with a new source
    When I go to  "/new claim"
    And I fill in "card_name" with "Hello World is a name of a new born baby"
    And I wait until ajax response
    And I fill in "sourcebox" with "http://google.com/?q=ymca"
    And I press "Add" within ".sourcebox"
    And I wait until ajax response
    # And I wait 60 seconds
    And I press "Submit"
    And I wait until ajax response
    Then I should not see "Problems with"
    And the card "Hello World is a name of a new born baby" should contain "google.com"

  Scenario: Creating a claim with a existing source
    When I go to "/new source"
    And I fill in "card_subcards__Link_content" with "http://example.com"
    And I press "Submit"
    And I go to  "/new claim"
    And I fill in "card_name" with "Hello World is a name of a new born baby"
    And I wait until ajax response
    And I fill in "sourcebox" with "http://example.com"
    And I press "Add" within ".sourcebox"
    And I wait until ajax response
    And I press "Submit"
    And I wait until ajax response
    Then I should not see "Problems with"
    And the card "Hello World is a name of a new born baby" should contain "example.com"

  Scenario: Creating a claim with a existing source card's url
    When I go to "/new source"
    And I fill in "card_subcards__Link_content" with "http://example.com"
    And I press "Submit"
    And I go to  "/new claim"
    And I fill in "card_name" with "Hello World is a name of a new born baby"
    And I wait until ajax response
    And I fill in "sourcebox" with card path of source with link "http://example.com"
    And I press "Add" within ".sourcebox"
    And I wait until ajax response
    And I press "Submit"
    And I wait until ajax response
    Then I should not see "Problems with"
    And the card "Hello World is a name of a new born baby" should contain "example.com"

  Scenario: Creating a claim with a source without pressing add
    When I go to  "/new claim"
    And I fill in "card_name" with "Hello World is a name of a new born baby"
    And I wait until ajax response
    And I fill in "sourcebox" with "http://google.com/?q=ymca"
    And I press "Submit"
    And I wait until ajax response
    Then I should not see "Problems with"
    And the card "Hello World is a name of a new born baby" should contain "google.com"
