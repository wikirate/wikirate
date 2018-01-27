@javascript
Feature: source
  In order to have source to support notes/metric values
  As a User
  I want to create a source

 Background:
   Given I am signed in as Joe Admin

 Scenario: Create a link source
   And I go to new Source
   And I fill in "card_subcards__Link_content" with "http://example.com"
   # And I fill in "card_subcards__Title_content" with "a test link source"
   And I press "Submit"
   Then I should not see "Problems with"
   # And I should see "a test link source"

 Scenario: create a file source
   And I go to new Source
   And I click "file-tab" within ".new-source-tab"
   And I upload the file "file.txt"
   Then I should see "file.txt 9 Bytes"
   # And I fill in "card_subcards__Title_content" with "a test file source"
   And I press "Submit"
   Then I should not see "Problems with"
  # And I should see "a test file source"



