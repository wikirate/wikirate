@javascript
Feature: source
  In order to have source to support notes/metric values
  As a User
  I want to create a source

 Background:
   Given I am signed in as Joe Admin
   And I go to new Source
   And I fill in "+Title" with "a test link source"
   And I fill in "+Year" with "2000"
   And I fill in "+Company" with "Death Star"
   And I fill in "+Report type" with "CSR Report"

 Scenario: Create a link source
   And I fill in "card_subcards__File_remote_file_url" with "http://example.com"
   And I press "Submit"
   Then I should not see "Problems with"
   And I should see "a test link source"

 Scenario: create a file source
   And I go to new Source
   And I upload the file "file.txt"
   Then I should see "file.txt 9 Bytes"
   And I press "Submit"
   Then I should not see "Problems with"
   And I should see "a test file source"



