@javascript
Feature: source citation
  While doing research the user is informed about presence or absence or misfit of
  years on sources when citing.

Background:
  Given I am signed in as Joe User

Scenario: Source has a year, answer form has a different year
  When I research answer "9" for year "2009"
  And I cite source for 2008
  And I press "Submit"
  Then I should see "The source you are citing is currently listed as a 2008 source"
  Then I should see "Please confirm that you wish to cite this source for a 2009 answer"
  When I confirm citation
  Then I should see "Cited"
  When I go to cited source
  Then I should see "2009"

Scenario: Source has no year
  When I research answer "9" for year "2009"
  And I cite source without year
  And I press "Submit"
  Then I should see "Please confirm that you wish to cite this source for a 2009 answer"
  When I confirm citation
  Then I should see "Cited"
  When I go to cited source
  Then I should see "2009"

Scenario: Cancel citation
  When I research answer "9" for year "2009"
  And I cite source without year
  And I press "Submit"
  Then I should see "Please confirm that you wish to cite this source for a 2009 answer"
  When I dismiss citation
  Then I should see "Cite!"
  And I should not see "Cited"



