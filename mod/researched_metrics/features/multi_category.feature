@javascript
Feature: Multi-Category
  As signed in user I can select more than one value for a multi-category value

  Scenario: Check und uncheck value for metric with few options
    When I am signed in as Joe User
    And I edit "Joe User+small multi+Sony Corporation+2010"
    And I check "3"
    And I uncheck "2"
    And I press "Save and Close"
    And I wait for ajax response
    Then I should see "1, 3"

#  FIXME: select step not working for multi-select
#  Scenario: Check und uncheck value for metric with many options
#    When I am signed in as Joe User
#    And I edit "Joe User+big multi+Sony Corporation+2010"
#    And I select "3" from "Answer"
#    #And I select "2" from "Answer"
#    And I submit
#    Then I should see "1, 3"

