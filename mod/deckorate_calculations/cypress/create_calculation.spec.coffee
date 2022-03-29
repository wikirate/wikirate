
describe "metric creation", ->
  hasProperty = (prop, label, value)->
    cy.get prop
      .should "contain", label
      .should "contain", value

  setValue = (value) ->
    cy.window().then (win) ->
      el = Cypress.$ ".codemirror-editor-textarea"
      (new win.decko.FormulaEditor el).area.setValue value

  beforeEach -> cy.login "joe@camel.com"

  describe "from new metric page", ->
    beforeEach -> cy.visit "new/Metric"

    specify "metric type: Descendant", ->
      cy.contains("Descendant").click()

      cy.contains("a", "Add Item").click()

      cy.get("._filter-container [name='filter[name]']").type "disturb{enter}"
      cy.get("input#Jedi_disturbances_in_the_Force").click()
      cy.get("._add-selected").click()
      cy.contains("Save as Metric").click()

      cy.get(".RIGHT-Xtitle .d0-card-content").type "MyChild"
      cy.contains("Submit").click()

      cy.get(".metric-properties").within ->
        hasProperty ".designer-property", "Designed by", "Joe Camel"
        hasProperty ".RIGHT-Xmetric_type", "Metric Type", "Descendant"

  describe.only "from variable metric page", ->
    beforeEach ->
      cy.visit "Jedi+friendliness"
      cy.contains("Calculations").click()

    specify "metric type: Formula", ->
      cy.contains("Add new Formula").click()

      cy.get(".new-formula-form").within ->
        cy.wait 500
        setValue "friendliness + 1"

      cy.contains("Save as Metric").should("not.have.attr", "disabled").click()

      cy.get(".RIGHT-Xtitle .d0-card-content").type "MyFormula"
      cy.contains("Submit").click()

      cy.get("span.metric-value").should "have.text", "1.1"
      cy.get(".RIGHT-formula").within ->
        cy.get("td").should "have.text", "friendliness"
        cy.get(".code").should "contain", "friendliness + 1"







#
#    specify "metric type: Score", ->
#      cy.contains("Score").click()
#
#    specify "metric type: WikiRating", ->
#      cy.contains("WikiRating").click()
