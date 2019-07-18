@javascript
Feature: Double check
  As signed in user I can double check and request checks for metric values

  Scenario: Can't check if not signed in
    When I go to card "Jedi+disturbances in the Force+Death Star+2000"
    And I click on "Yes, I checked"
    And I wait for ajax response
    Then I should see "Please sign in"

  Scenario: Check and undo
    When I am signed in as Joe User
    And I go to card "Jedi+disturbances in the Force+Death Star+2000"
    Then I should see "Nobody has checked this value"
    And I click on "Yes, I checked"
    Then I should see "Joe User checked this value"
    And I should see "Uncheck"

    When I am signed in as Joe Admin
    And I go to card "Jedi+disturbances in the Force+Death Star+2000"
    Then I should see "Joe User checked this value"
    When I click on "Yes, I checked"
    Then I should see "Joe User and Joe Admin checked this value"

    When I am signed in as Joe User
    And I go to card "Jedi+disturbances in the Force+Death Star+2000"
    And I click on "Uncheck"
    Then I should see "Joe Admin checked this value"
    And I should see "Yes, I checked"

  Scenario: Request check, check and undo
    When I am signed in as Joe User
    And I go to card "Jedi+disturbances in the Force+Death Star+2000"
    And I edit "Jedi+disturbances in the Force+Death Star+2000"
    And I check "request"
    And I press "Save"
    And I wait for ajax response
    Then I should see "Double check requested by Joe User"

    When I am signed in as Joe Admin
    And I go to card "Jedi+disturbances in the Force+Death Star+2000"
    And I click on "Yes, I checked"
    Then I should see "Joe Admin checked this value"

    When I click on "Uncheck"
    Then I should see "Double check requested by Joe User"
    When I edit "Jedi+disturbances in the Force+Death Star+2000"
    Then I should not see "request"

    When I am signed in as Joe User
    And I edit "Jedi+disturbances in the Force+Death Star+2000"
    And I uncheck "request"
    And I scroll 300 pixels down
    And I press "Save"
    Then I should not see "Joe User checked"
    And I should not see "requested by Joe User"

    When I am signed in as Joe Admin
    And I go to card "Jedi+disturbances in the Force+Death Star+2000"
    Then I should see "Yes, I checked"

  Scenario: Check is removed if value is edited and same user can't double check
    When I am signed in as Joe User
    And I go to card "Jedi+disturbances in the Force+Death Star+2000"
    When I click on "Yes, I checked"
    And I wait for ajax response
    Then I should see "Joe User checked this value"
    When I edit "Jedi+disturbances in the Force+Death Star+2000"
    And I fill in "no" for "Answer"
    And I scroll 300 pixels down
    And I press "Save"
    Then I should not see "Joe User checked this value"

