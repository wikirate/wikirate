@javascript
Feature: metric value
   As signed in user I want to be able to add a metric value.

  Background:
    Given I am signed in as Joe User
    And I wait until ajax response done
    And I go to  "/new metric_value"
    And I wait until ajax response done

  Scenario: create a metric value with a link source on new metric value page
    When I solocomplete "Jedi+disturbances in the Force" within ".RIGHT-metric"
    And I fill in metric value with "Death Star" as company, "2015" as year, and "boom" as value
    And I fill in source url with "http://wagn.org"
    And I press "Submit"
    And I wait until ajax response done
    Then I should see "Jedi+disturbances in the Force+Death Star+2015"
    And I should see "boom"
    And I should see "wagn.org"
    And I should see "2015"

  Scenario: create a metric value with a invalud link source on new metric value page
    When I solocomplete "Jedi+disturbances in the Force" within ".RIGHT-metric"
    And I fill in metric value with "Death Star" as company, "2015" as year, and "boom" as value
    And I fill in source url with "wagn.org"
    And I press "Submit"
    And I wait until ajax response done
    Then I should see "Problems"
    # FIXME: 'link' shouldn't appear twice
    # also the full error message appears twice
    # and we get errors with the title
    # Page-000...
    And I should see "+LINK: link invalid uri wagn.org"

  Scenario: create a metric value with a file source on new metric value page
    When I solocomplete "Jedi+disturbances in the Force" within ".RIGHT-metric"
    And I fill in metric value with "Death Star" as company, "2015" as year, and "101" as value
    And I click "file-tab" within ".new-source-tab"
    And I upload the file "file.txt"
    And I wait until ajax response done
    Then I should see "file.txt 9 Bytes"
    And I press "Submit"
    And I wait until ajax response done
    And I should see "Jedi+disturbances in the Force+Death Star+2015"
    And I should see "101"
    And I should see "Page-"
    And I should see "2015"

  Scenario: create a metric value with nothing on new metric value page

    When I press "Submit"
    And I wait until ajax response done
    And I should see "FIELD: Missing metric. Please check before submit."
    And I should see "FIELD: Missing value. Please check before submit."
    And I should see "FIELD: Missing year. Please check before submit."
    And I should see "FIELD: Missing company. Please check before submit."

  Scenario: update a metric value
    When I go to card "Jedi+disturbances in the Force"
    And I wait until ajax response done
    And In the main card content I click "Add new value"
    And I fill in metric value with "Death Star" as company, "2015" as year, and "101" as value
    And I fill in source url with "http://example.com"
    And I press "Submit"
    And I press "Close"
    # FIXME the new metric should appear witout reloading the page
    And I edit card "Jedi+disturbances in the Force+Death Star+2015"
    And I fill in "card_subcards_Jedi_disturbances_in_the_Force_Death_Star_2015_value_content" with "100"
    And I press "Submit"
    And I wait until ajax response done
    When I go to card "Death Star"
    Then I should see "100"