@javascript
Feature: import#  metric values from a csv file
  A user can create metric values from a CSV file

 Background:
   Given I am signed in as Joe Camel
   And I go to new Metric Answer Import File
   And I fill in "card_name" with "Strikes tmr?"
   And I upload the metric_value_import_file "answer_import.csv"
   And I wait for ajax response
   And I press "Submit"
   And I wait for ajax response
   And I maximize the browser
   And I uncheck all checkboxes
   And I scroll -1000 pixels

 Scenario: Import a simple metric value
   And I should see a row with "1|Jedi+disturbances in the Force|Death Star|Death Star|Death Star|2017|yes|http://google.com/1|chch"
   And I should see a row with "11|Jedi+disturbances in the Force|Death Star|2000|no|http://google.com/10"

   When I check checkbox for csv row 1
   When I check checkbox for csv row 11
   And I select "override" from "conflict strategy"
   And I press "Import"
   And I wait for ajax response
   Then I should see "Importing 1 metric answers ..."
   When Jobs are dispatched
   And I wait 2 seconds
   Then I should see "Imported 1 metric answers"
   And I should see "Successful"
   And I should see "#1:Jedi+disturbances in the Force+Death Star+2017"
   And I should see "Overriden"
   And I should see "#11:Jedi+disturbances in the Force+Death Star+2000"

   Then I click on "Undo"
   When I go to "#1:Jedi+disturbances in the Force+Death Star+2017"
   Then I should see "doesn't exist"
   When I go to "#11:Jedi+disturbances in the Force+Death Star+2000"
   Then I should see "yes"




