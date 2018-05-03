@javascript
Feature: source citation
  While doing research the user is informed about presence or absence or misfit of
  years on sources when citing.

Background:
  Given I am signed in as Joe User

Scenario: Source has a year, answer form has a different year
  When I research answer "9" for year "2009"
  And I cite source for 2008 confirming
    """
    The source you are citing is currently listed as a source for 2008.
    Please confirm that you wish to cite this source for a 2009 answer
    (and add 2009 to the years covered by this source).
    """
  And I press "Submit"
  Then I should see "Cited"
  When I visit cited source
  Then I should see "2009"

Scenario: Source has no year
  When I research answer "9" for year "2009"
  And I cite source without year confirming
    """
    Please confirm that you wish to cite this source for a 2009 answer
    """
  And I press "Submit"
  Then I should see "Cited"
  When I visit cited source
  Then I should see "2009"

Scenario: Cancel citation
  When I research answer "9" for year "2009"
  And I cite source without year dismissing
    """
    Please confirm that you wish to cite this source for a 2009 answer
    """
  And I press "Submit"
  Then I should see "Cite!"
  And I should not see "Cited"



