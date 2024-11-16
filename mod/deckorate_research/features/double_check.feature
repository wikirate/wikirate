@javascript
Feature: Double check
  As signed in user I can double check and request checks for metric values

  Scenario: Can't check if not signed in
    When I go to card "Jedi+disturbances in the Force+Death Star+2000"
    And I click on "Review"
    And I switch to new tab
    And I click on "Confirm Record"
    And I wait for ajax response
    Then I should see "Please log in"

  Scenario: Check and undo
    When I am signed in as Joe User
    And I go to card "Jedi+disturbances in the Force+Death Star+2000"
    And I click on "Review"
    And I switch to new tab
    Then I should see "Verifications 0"
    And I click on "Confirm Record"
    Then I should see "Verification 1"
    And I should see "Joe User"
    And I should see "Un-confirm"

    When I am signed in as Joe Admin
    And I wait a sec
    And I go to card "Jedi+disturbances in the Force+Death Star+2000"
    And I click on "Review"
    And I switch to new tab
    Then I should see "Verification 1"
    And I should see "Joe User"
    When I click on "Confirm Record"
    Then I should see "Verifications 2"

    When I am signed in as Joe User
    And I go to card "Jedi+disturbances in the Force+Death Star+2000"
    And I click on "Review"
    And I switch to new tab
    And I click on "Un-confirm"
    Then I should see "Verification 1"
    And I should see "Joe Admin"
    And I should see "Confirm Record"

  Scenario: Check is removed if value is edited and same user can't double check
    When I am signed in as Joe User
    And I go to card "Jedi+disturbances in the Force+Death Star+2000"
    And I click on "Review"
    And I switch to new tab
    When I click on "Confirm Record"
    And I wait for ajax response
    Then I should see "Verification 1"
    When I edit "Jedi+disturbances in the Force+Death Star+2000"
    And I check "no"
    And I scroll 300 pixels down
    And I press "Save and Close"
    And I click on "Review"
    And I switch to new tab
    Then I should see "Verifications 0"
