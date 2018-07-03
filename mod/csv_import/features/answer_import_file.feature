@javascript @delayed-jobs
Feature: import metric answers from a csv file
  A user can create metric answers from a CSV file

  Background:
    Given I am signed in as Joe Admin
    And I go to card "feature answer import test"
    And I follow "Import ..."
#    And I maximize the browser
    # And I uncheck all checkboxes
    And I check "all"
    And I uncheck "all"
    And I scroll -1000 pixels

  Scenario: Show import table correctly
    And I should see a row with "1|Jedi+disturbances in the Force|Death Star|Death Star|Death Star|2017|yes|http://google.com/1|chch"
    And I should see a row with "11|Jedi+disturbances in the Force|Death Star|2000|no|http://google.com/10"

  Scenario: Import a simple metric value
    When I check checkbox for csv row 1
    And I scroll 1000 pixels down
    And I press "Import"
    Then I should see "Importing 1 metric answer ..."
    When Jobs are dispatched
    And I wait for ajax response
    Then I should see "Imported 1 metric answer"
    And I should see "Successful"
    And I should see "#1: Jedi+disturbances in the Force+Death Star+2017"
    Then I follow "Jedi+disturbances in the Force+Death Star+2017"
    And I should see "2017"
    And I should see "yes"
    And I should see a "comment" icon
    And I should see "chch"

  Scenario: Import simple metric values with same source
    When I import rows 1, 2, 3, 4, 6, 9, 10, 11, 12
    Then I should see "4 imported"
    And I should see "4 skipped"
    And I should see "1 failed"
    And I should see "#6: A is not a company"
    And I should see "#10: Jedi+disturbances in the Force+Death Star+2000 - Jedi+disturbances in the Force+Death Star+2000 duplicate in this file"
    And I should see "#4: Jedi+disturbances in the Force+New Company+2017"


    # there is no solution yet how to get the earned badges in iwd stage
#  Scenario: Award badges
#    And I check checkbox for csv row 13
#    And I check checkbox for csv row 14
#    And I check checkbox for csv row 15
#    And I press "Import"
#    And I wait for ajax response
#    When Jobs are dispatched
#    Then I should see "Monster Inc Researcher"
#    And I should see "Inside Source"
#    And I wait 5 seconds
#    And I go to card "Joe Admin+metric values+badges earned"
#    Then I should see "Monster Inc Company Awarded for adding 3 answers about Monster Inc"
#    And I go to card "Joe Admin+source+badges earned"
#    And I should see "Inside Source"

