Feature: import metric values from a csv file
  A user can create metric values from a CSV file

  Background:
    Given I am signed in as Joe User
    And I wait until ajax response done

  Scenario: Import a metric value
    When I go to new metric_value_import_file
    And I upload the mod file "metric_values_import.csv"
    And I wait until ajax response done

#  Scenario:  Creating a researched metric
#    When I go to new metric
#    And I choose "Researched"
#    And I fill in "Metric Title" with "MyResearch"
#    And I fill in "card[subcards][+question][content]" with "my question"
#    And I select "Number" from hidden "card_subcards__value_type_content"
#    And I press "Submit"
