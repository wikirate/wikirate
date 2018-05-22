@javascript
Feature: Join a Research Group
  As signed in user I want to be able to join a Research Group

  Background:
    Given I am signed in as Joe User

  Scenario: Research group
    When I go to card "Jedi"
    And I click "Join"
    Then I should see a row with "Joe User"
