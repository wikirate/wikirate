@javascript
Feature: Research answer fail
  As signed in user if I try to add a new answer I should get
  a decent error message if important data is missing.

  Background:
    Given I am signed in as Joe User
    And I research
      | metric              | company    | year |
      | Joe User+researched | Apple Inc. | 2009 |

  Scenario: Missing value
    And I cite source
    And I fill in "Baam!" for " Comment"
    And I press "Submit"
    And I should see "Problems"
    And I should see "+VALUES: content: Only numeric content is valid for this metric."

  Scenario: Missing source
    And I fill in "10" for "Answer"
    And I fill in "Baam!" for " Comment"
    And I press "Submit"
    And I should see "Problems"
    And I should see "SOURCE: no source cited"
