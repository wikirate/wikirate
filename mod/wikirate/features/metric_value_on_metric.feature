#@javascript
#Feature: metric value
#   As signed in user I want to be able to add a metric value on metric page.
#
#  Background:
#    Given I am signed in as Joe User
#    And I wait until ajax response done
#
#  Scenario: Adding a metric value with a link source on metric page
#    When I go to card "Jedi+disturbances in the Force"
#    And I wait until ajax response done
#    And In the main card content I click "Add new value"
#    And I fill in company with "Death Star"
#    And I fill in year with "2015"
#    And I fill in value with "101"
#    And I fill in source url with "http://example.com"
#    And I press "Submit"
#    And I press "Close"
#    # FIXME the new metric should appear witout reloading the page
#    And I go to card "Jedi+disturbances in the Force"
#    Then I should see "Death Star"
#    When I go to card "Death Star"
#    Then I should see "101"
#
#  Scenario: Adding a metric value with a file source on metric page
#    When I go to card "Jedi+disturbances in the Force"
#    And I wait until ajax response done
#    And In the main card content I click "Add new value"
#    And I fill in company with "Death Star"
#    And I fill in year with "2015"
#    And I fill in "card_subcards__value_content" with "101"
#    And I click "file-tab" within ".new-source-tab"
#    And I upload the file "file.txt"
#    And I wait until ajax response done
#    Then I should see "file.txt 9 Bytes"
#    And I press "Submit"
#    And I press "Close"
#    # FIXME the new metric should appear witout reloading the page
#    And I go to card "Jedi+disturbances in the Force".
#    Then I should see "Death Star"
#    When I go to card "Death Star"
#    Then I should see "101"
