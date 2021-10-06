toAnswerPhase = (metric, company, year)->
  cy.visit "#{metric}+#{company}/research?year=#{year}&tab=answer_phase"

testUnknown = (value) ->
  cy.get("#_unknown").should "not.be.checked"
  lookupValueContent().should "eq", value

  cy.get("#_unknown").check().should "be.checked"
  lookupValueContent().should "eq", "Unknown"

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

describe "the 'unknown' checkbox", ->
  before ->
    cy.login("sample@user.com", "sample_pass")

  specify "numeric metric", ->
    toAnswerPhase "Jedi+deadliness", "Death Star", "2020"
    testUnknown ""
    cy.get(edSelector(".short-input")).clear().type "42"
    cy.get(".RIGHT-discussion textarea").focus() # move focus to trigger change event
    testUnknown "42"