@javascript @delayed-jobs
Feature: create new import file card
  A user can upload a new csv file and use it to import metric answers.

 Background:
   Given I am signed in as Joe Camel
   And I go to new Metric Answer Import File
   And I fill in "card_name" with "another import"
   And I upload the answer_import_file "answer_import.csv"
   And I wait for ajax response
   And I press "Submit"
   And I wait for ajax response
#    And I maximize the browser
   And I uncheck all checkboxes

 Scenario: Import a simple metric value
   And I should see a row with "1|Jedi+disturbances in the Force|Death Star|Death Star|Death Star|2017|yes|http://google.com/1|chch"
   And I should see a row with "11|Jedi+disturbances in the Force|Death Star|2000|no|http://google.com/10"
   And I choose "override"
   When I check checkbox for csv row 1
   And I check checkbox for csv row 11
   And I scroll 1000 pixels down
   And I press "Import"
   And I wait for ajax response
   Then I should see "Importing 2 metric answers ..."

   When Jobs are dispatched
   Then No errors in the job queue
   And I wait 2 seconds
   Then I should see "1 metric answer created and 1 metric answer updated"
   And I should see "Successful"
   And I should see "#1: Jedi+disturbances in the Force+Death Star+2017"
   And I should see "Overridden"
   And I should see "#11: Jedi+disturbances in the Force+Death Star+2000"

   Then I click on "Undo"
   When I go to card "Jedi+disturbances in the Force+Death Star+2017"
   Then I should see "doesn't exist"
   When I go to card "Jedi+disturbances in the Force+Death Star+2000"
   Then I should see "yes"




