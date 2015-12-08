@javascript
Feature: note
   As signed in user I want to be able to create a new metric and add a value.

  Background:
    Given I am signed in as Joe User
    And I wait until ajax response done

  Scenario: Creating a new metric and adding a value
    When I go to  "/new metric"
    And I fill in "card_name" with "Jedi+size"
    And I press "Submit"
    And In the main card content I click "Add new value"
    And I fill in "pointer_item" with "Death Star" within "form > fieldset.editor > .RIGHT-company"
    And I fill in "pointer_item" with "2015" within "form > fieldset.editor > .RIGHT-year"
    And I fill in "card_subcards__value_content" with "101"
    And I fill in "card_subcards__source_subcards_new_source_subcards__Link_content" with "http://example.com"
    And I press "Submit"
    And I press "Close"
    # FIXME the new metric should appear witout reloading the page
    And I go to card "Jedi+size"
    Then I should see "Death Star"
    When I go to card "Death Star"
    Then I should see "101"

  Scenario: Creating a new metric with a file source on metric page
    When I go to  "/new metric"
    And I fill in "card_name" with "Jedi+size"
    And I press "Submit"
    And In the main card content I click "Add new value"
    And I fill in "pointer_item" with "Death Star" within "form > fieldset.editor > .RIGHT-company"
    And I fill in "pointer_item" with "2015" within "form > fieldset.editor > .RIGHT-year"
    And I fill in "card_subcards__value_content" with "101"
    And I click "file-tab" within ".new-source-tab"
    And I upload the file "file.txt"
    And I wait until ajax response done
    Then I should see "file.txt 9 Bytes"

    And I press "Submit"
    And I press "Close"
    # FIXME the new metric should appear witout reloading the page
    And I go to card "Jedi+size".
    Then I should see "Death Star"
    When I go to card "Death Star"
    Then I should see "101"
