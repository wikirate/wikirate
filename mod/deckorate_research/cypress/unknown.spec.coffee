toAnswerPhase = (metric, company, year)->
  year ||= 2020
  company ||= "Sony_Corporation"
  cy.visit "#{metric}+#{company}/research?year=#{year}&tab=answer_phase"

# check and uncheck unknown box, ensuring desired effects
testUnknown = (value) ->
  cy.get("#_unknown").should "not.be.checked"
  lookupValueContent().should "eq", value

  cy.get("#_unknown").check().should "be.checked"
  shiftFocus()
  lookupValueContent().should "eq", "Unknown"

# for finding content editor
edSelector = (klass) ->
  ".card-editor.RIGHT-value .content-editor #{klass}"

# this is a little complex, because we need to call the setContentFieldsFromMap method
# that actually calculates the value before the form is submitted in order to confirm
# that all the effects of checking and unchecking "unknown" are working. That method
# extends the jQuery object and is evidently unavailable in the more standard
# cypress route for jQuery calls (Cypress.$)
lookupValueContent = ->
  cy.window().then (win) ->
    win.eval "$('.card-form').setContentFieldsFromMap();"
  cy.wrap(content: valueContent).invoke('content')

valueContent = ->
  Cypress.$("[name='card[subcards][+values][content]']").val()

# move focus to trigger change event
shiftFocus = ->
  cy.get(".RIGHT-discussion textarea").focus()

describe "the 'unknown' checkbox", ->
  beforeEach ->
    cy.login "sample@user.com", "sample_pass"

  specify "numeric metric", ->
    toAnswerPhase "Jedi+deadliness", "Death_Star"
    testUnknown ""
    cy.get(edSelector(".short-input")).clear().type "42"
    shiftFocus()
    testUnknown "42"

  specify "metric with checkboxes", ->
    toAnswerPhase "Joe_User+small_multi"
    testUnknown ""
    cy.get(edSelector(".pointer-checkbox-button")).click(multiple: true)
    shiftFocus()
    testUnknown "[[1]]\n[[2]]\n[[3]]"

  specify "metric with radios", ->
    toAnswerPhase "Joe_User+small_single"
    testUnknown ""
    cy.get(edSelector("#pointer-radio-3")).click()
    shiftFocus()
    testUnknown "[[3]]"

  specify "metric with select", ->
    toAnswerPhase "Joe_User+big_single"
    testUnknown ""
    cy.get(edSelector("select")).select2 "7"
    shiftFocus()
    testUnknown "[[7]]"
