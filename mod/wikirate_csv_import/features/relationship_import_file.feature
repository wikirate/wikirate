@javascript @delayed-jobs
Feature: import metric answers from a csv file
  A user can create metric relationship answers from a CSV file

  Background:
    Given I am signed in as Joe Admin
    And I go to card "feature relationship import test"
    And I follow "Import ..."

#  Scenario: Show import table correctly
#    And I should see a row with "1|Jedi+disturbances in the Force|Death Star|Death Star|Death Star|2017|yes|http://google.com/1|chch"
#    And I should see a row with "11|Jedi+disturbances in the Force|Death Star|2000|no|http://google.com/10"
#
#  Scenario: Import a simple metric value
#    When I check checkbox for csv row 1
#    And I scroll 1000 pixels down
#    And I press "Import"
#    Then I should see "Importing 1 metric answer ..."
#    When Jobs are dispatched
#    And I wait for ajax response
#    Then I should see "Imported 1 metric answer"
#    And I should see "Successful"
#    And I should see "#1: Jedi+disturbances in the Force+Death Star+2017"
#    Then I follow "Jedi+disturbances in the Force+Death Star+2017"
#    And I should see "2017"
#    And I should see "yes"
#    And I should see a "comment" icon
#    And I should see "chch"
#
#  Scenario: Import simple metric values with same source
#    When I check checkbox for csv row 1
#    And I check checkbox for csv row 2
#    And I check checkbox for csv row 3
#    And I check checkbox for csv row 4
#    And I check checkbox for csv row 6
#    And I check checkbox for csv row 9
#    And I check checkbox for csv row 10
#    And I check checkbox for csv row 11
#    And I check checkbox for csv row 12
#
#    And I scroll 1000 pixels down
#    And I press "Import"
#    And I wait 1 second
#    When Jobs are dispatched
#    And I wait 3 seconds
#    And I wait for ajax response
#    Then I should see " imported"
#    And I should see "4 skipped"
#    And I should see "1 failed"
#    And I should see "#6: A is not a company"
#    And I should see "#10: Jedi+disturbances in the Force+Death Star+2000 - Jedi+disturbances in the Force+Death Star+2000 duplicate in this file"
#    And I should see "#4: Jedi+disturbances in the Force+New Company+2017"

  Scenario: Import introduces new company alias
    And I imported rows 1
    And I wait 2 seconds
    Then I should see "1 imported"
    When I go to card "Sony Corporation+aliases"
    Then I should see a prompt to add "Sony"
