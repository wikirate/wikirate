@javascript
Feature: Unknown
  The user interface doesn't allow to enter a value and choose unknown at the same time

  Background:
    Given I am signed in as Joe User

  Scenario: Numeric metric
    When I edit answer of "Jedi+deadliness" for "Death Star" for "1977"
    Then Unknown should not be checked
    When I check "Unknown"
    Then value input field should be disabled and empty
    When I uncheck "Unknown"
    Then value input field should not be disabled

  Scenario: Metric with checkboxes
    When I edit answer of "Joe User+small multi" for "Sony Corporation" for "2010"
    Then Unknown should not be checked
    When I check "Unknown"
    Then value input field should be disabled and empty
    When I uncheck "Unknown"
    Then value input field should not be disabled

  Scenario: Metric with radio buttons
    When I edit answer of "Joe User+small single" for "Sony Corporation" for "2010"
    Then Unknown should not be checked
    When I check "Unknown"
    Then value input field should be disabled and empty
    When I uncheck "Unknown"
    Then value input field should not be disabled

  Scenario: Metric with select field
    When I edit answer of "Joe User+big single" for "Sony Corporation" for "2010"
    Then Unknown should not be checked
    When I check "Unknown"
    Then value select field should be disabled and empty
    When I uncheck "Unknown"
    Then value select field should not be disabled
