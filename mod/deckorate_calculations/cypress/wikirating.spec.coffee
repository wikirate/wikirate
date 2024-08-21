describe 'edit Rating', ->
  setWeight = (name, weight) ->
    cy.get("[data-card-name='#{name}']")
      .closest('.row')
      .find("[name=pair_value]")
      .clear()
      .type weight

  expectTotalWeight = (weight) ->
    cy.get("input#weight_sum").should "have.value", weight

  beforeEach -> cy.login()

  specify "Rating formula", ->
    cy.visit "Jedi+darkness rating"

    # go to details tab
    cy.contains("Details").click()

    cy.slot "jedi+darkness_rating+*variable"
      .find(".card-menu > a.edit-link").click(force: true)
    cy.contains("a", "Add Metric", timeout: 15000)
      .click()
    cy.get("._filter-container [name='filter[name]']")
      .type("dead{enter}")
    cy.wait 300
    cy.get("input[name='Jedi+deadliness+Joe Camel']")
      .click()
    cy.contains("Add Selected")
      .click().should "not.exist"

    cy.get("._modal-slot").within ($modal) ->
      expect($modal).to.contain "Score"
      expectTotalWeight "100.00"
      cy.contains("Save and Close").should "have.attr", "disabled"

    setWeight "Jedi+deadliness+Joe Camel", "30"
    expectTotalWeight "130.00"
    cy.contains("Save and Close").should "have.attr", "disabled"
    setWeight "Jedi+deadliness+Joe User", "30"
    expectTotalWeight "100.00"
    cy.contains("Save and Close").should "not.have.attr", "disabled"
    cy.el("submit-modal").click()
    cy.slot("jedi+darkness_rating+*variable")
      .should "contain", "30"
      .and "contain", "40"
      .and "not.contain", "100.00"

    cy.main_slot().should "contain", "Rating"



