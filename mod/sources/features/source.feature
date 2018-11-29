@javascript
Feature: source
  In order to have source to support notes/metric values
  As a User
  I want to create a source

 Background:
   Given I am signed in as Joe Admin
   And I go to new Source
   And I fill in "+Title" with "a test source"
   And I fill in "+Company" with "Death Star"
   And I select2 "2000" from "pointer_multiselect--year-2[]"
   And I select2 "Hologram Report" from "pointer_multiselect--report_type-1[]"

 Scenario: Create a link source
   And I fill in "card_subcards__File_remote_file_url" with "http://example.com"
   And I press "Submit"
   Then I should not see "Problems with"
   And I should see "a test source"

 Scenario: create a file source
   And I upload the file "file.txt"
   Then I should see "file.txt 9 Bytes"
   And I press "Submit"
   Then I should not see "Problems with"
   And I should see "a test source"



