
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
      cy.get("._filter-items").should "not.contain", "less evil"
      cy.get("input#Jedi_disturbances_in_the_Force").click()
      cy.get("._add-selected").click()
      cy.contains("Save as Metric").click()

      cy.get(".RIGHT-Xtitle .d0-card-content").type "MyChild"
      cy.contains("Submit").click()

      cy.get(".alert").should "contain", "Metric Creator"
        .should "contain", "Awarded for adding your first metric"

      cy.get(".header-middle")
        .should "contain", "Designer"
        .should "contain", "Joe Camel"
        .should "contain", "Metric Type"
        .should "contain", "Descendant"


  describe "from variable researched metric page", ->
    beforeEach ->
      # metric page
      cy.visit "Jedi+friendliness"

      # calculations tab
      cy.contains("Calculations").click()

    specify "metric type: Formula", ->
      # new formula button
      cy.contains("Add new Formula").click()

      cy.get(".new-formula-form").within ->
        # make sure sample values are loading and formula is getting run
        cy.get("._sample-result-value").should "have.text", "invalid formula"

        # add a valid formula
        cy.wait 400
        setValue "friendliness + 1"

      # click to save as metric
      cy.contains("Save as Metric").click()

      # add a name and save
      cy.get(".RIGHT-Xtitle .d0-card-content").type "MyFormula"
      cy.contains("Submit").click()

      # check that an answer exists
      cy.get("span.metric-value").should "contain", "1.1"

      # go to details tab
      cy.contains("Details").click()

      # check that formula looks right
      cy.get(".RIGHT-formula").within ->
        cy.get("td").should "contain", "friendliness"
        cy.get(".code").should "contain", "friendliness + 1"


    specify "metric type: Score", ->
      # new score button
      cy.contains("Add new Score").click()

      cy.get(".new-formula-form").within ->
        # make sure sample values are loading and formula is getting run
        cy.get("._sample-result-value").should "have.text", "invalid formula"

        # add a valid formula
        setValue "answer + 1"

      # click to save as metric
      cy.contains("Save as Metric").click()

      # save as metric
      cy.contains("Submit").click()

      # check that an answer exists
      cy.get("span.metric-value").should "contain", "1.1"

      # go to details tab
      cy.contains("Details").click()

      # check that formula looks right
      cy.get(".RIGHT-formula").within ->
        cy.get(".code").should "contain", "answer + 1"

  describe "from variable score metric page", ->
    beforeEach ->
      # metric page
      cy.visit "Jedi+disturbances in the force+Joe User"

      # calculations tab
      cy.contains("Calculations").click()

    specify "metric type: WikiRating", ->

      # new formula button
      cy.contains("Add new WikiRating").click()

      cy.get("#pair_value").clear().type("100")

      # click to save as metric
      cy.contains("Save as Metric").click()

      # add a name and save
      cy.get(".RIGHT-Xtitle .d0-card-content").type "MyWikiRating"
      cy.contains("Submit").click()

      # check that an answer exists
      cy.get("span.metric-value").should "contain", "10"

      # go to details tab
      cy.contains("Details").click()

      # check that formula looks right
      cy.get(".RIGHT-Xvariable").should "contain", "disturbance"
