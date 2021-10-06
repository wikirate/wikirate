toAnswerPhase = (metric, company, year)->
  cy.visit "#{metric}+#{company}/research?year=#{year}&tab=answer_phase"

checkingUnknown = ->
  cy.get("#unknown")
    .should "not.be.checked"
    .check()
    .should "be.checked"
  expect(valueContent()).to.equal ""

valueContent = ->
  cy.get('.card-form').setContentFieldsFromMap()
  cy.get("[name='card[subcards][+values][content]']").val()

describe "the 'unknown' checkbox", ->
  specify "numeric metric", ->
    toAnswerPhase "Jedi+deadliness", "Death Star", "1977"
    checkingUnknown()