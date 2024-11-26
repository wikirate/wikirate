describe 'Formula editor', ->
  beforeEach ->
    cy.login()
    cy.visit "Jedi+friendliness+formula"
    cy.slot "jedi+friendliness+formula"
      .find ".card-menu > a.edit-link"
      .click force: true

  setValue = (value) ->
    cy.window().then (win) ->
      el = Cypress.$ ".codemirror-editor-textarea"
      (new win.decko.FormulaEditor el).area.setValue value

  testFormula = (formula, result, disabled) ->
    setValue formula
    cy.get("._sample-result-value").should "have.text", result
    op = disabled && "have.attr" || "not.have.attr"
    cy.get(".submit-button").should op, "disabled"

  specify "adding and removing a variable", ->
    # open filtered list and choose new metric
    cy.contains("a", "Add Variable", timeout: 15000)
      .click force: true
    cy.get("._filter-container [name='filter[metric_keyword]']")
      .type("disturb{enter}", force: true)
    cy.wait 500
    cy.get("._search-checkbox-list")
      .should("contain", "Research")
      .should("contain", "Score")
      .should("not.contain", "Relationship")
    cy.get("input#Jedi_disturbances_in_the_Force").click()
    cy.get("._add-selected").click()

    # old variable still there
    cy.get("._filtered-list .row:first input._variable-name").should "have.value", "m1"

    # new variable
    cy.get("._filtered-list .row:last").within () ->
      # autonames from
      cy.get("input._variable-name").should "have.value", "disturbances"
      cy.get("._formula_options").should "contain", "(default)"
        .get("._edit-variable-options").should "be.hidden"
      cy.get("._sample-value").should "have.value", '"no"'

    # updates answers
    cy.get(".tab-li-answer").click()
    cy.get("._answer-board ._ab-total").should "have.text", "3"

    # remove row
    cy.get("._filtered-list .row:last").within () ->
      cy.get("._remove-variable").click()

    # only old row remains
    cy.get("._filtered-list .row").should "have.length", 1
    cy.get("input._variable-name").should "have.value", "m1"

    cy.get("._answer-board ._ab-total").should "have.text", "8"


#  specify "editing options", ->
#    cy.get("._formula_options").should "contain", "(default)"
#      .get("._edit-variable-options").should "be.hidden"
#
#    # open Answers tab
#    cy.get(".tab-li-answer a").click force: true
#    # There is one answer that is "unknown via options", meaning it's unknown based on
#    # the formula option configuration alone (not the formula processing)
#    cy.get "._answer-board ._ab-result-unknown-count"
#      .should "have.text", "1"
#      .should "not.be.hidden"
#
#    # choose "Any Researched"
#    cy.get("._options-scheme").select2("Any Researched")
#
#    # show options
#    cy.get("._formula_options").should "include.text", "unknown: Unknown"
#      .get("._edit-variable-options").should "be.hidden"
#
#    # open Answers tab
#    cy.get(".tab-li-answer a").click force: true
#    cy.get "._answer-board ._ab-result-unknown-count"
#      .should "have.text", "0"
#      .should "be.hidden"
#
#    # choose "Custom"
#    cy.get("._options-scheme").select2("Custom")
#
#    # retains previous settings
#    cy.get("._formula_options").should "include.text", "unknown: Unknown"
#      .get("._edit-variable-options").should "not.be.hidden"
#      .click force: true
#
#    # choose "no result" for Unknown
#    cy.get("[name=vo-unknown]:visible").check("no_result")
#
#    # update / close modal
#    cy.wait 300
#    cy.contains("Update Options").click()
#
#    # make sure changes show
#    cy.get("._formula_options").should "include.text", "unknown: no_result"
#
#    # make sure changes take effect in answers
#    cy.get "._answer-board ._ab-result-unknown-count"
#      .should "be.hidden"
#
#    # choose "All Researched"
#    cy.get("._options-scheme").select2("All Researched (default)")
#    cy.get("._formula_options").should "contain", "(default)"
#      .get("._edit-variable-options").should "be.hidden"

#  specify "edit formula", ->
#    cy.wait 100
#    testFormula "m1 * 20", "2000", false
#
#    # form submission is disabled when there are errors
#    testFormula "nerd * 2", "nerd is not defined", true
#    testFormula "if m1", "invalid formula", true
#    testFormula "m1 / 0", "Infinity", true
#
#    # ...and re-enabled when there are not
#    testFormula "1 / m1", "0.01", false

#  specify "edit variable value", ->
#    cy.get "._sample-result-value"
#      .should "have.text", "0.01"
#
#    cy.get "._sample-value"
#      .should "have.value", "100"
#      .clear force: true
#      .type "50", force: true
#
#    cy.get "._sample-result-value"
#      .should "have.text", "0.02"


#  specify "edit variable name", ->
#
#    cy.get "input._variable-name"
#      .should "have.value", "m1"
#      .type "{backspace}agic", force: true
#
#    cy.get("._formula-editor").should "contain", "magic"
