describe 'edit metric formulas', ->
  setWeight = (name, weight) ->
    cy.get("[data-card-name='#{name}']")
      .closest('tr')
      .find("[name=pair_value]")
      .clear()
      .type weight

  expectTotalWeight = (weight) ->
    cy.get("input#weight_sum").should "have.value", weight

  before =>
    cy.login()
    cy.ensure(
      "Jedi+darkness rating+formula",
      '{"Jedi+deadliness+Joe User":"60","Jedi+disturbances in the Force+Joe User":"40"}'
    )

  specify 'WikiRating formula', =>
    cy.visit "Jedi+darkness rating"
    cy.slot "jedi+darkness_rating+formula"
      .find(".card-menu > a").click(force: true)
    cy.contains("a", "add metric", timeout: 15000)
      .click()
    cy.get("input[name='Jedi+deadliness+Joe Camel']")
      .click()
    cy.contains("Add Selected")
      .click().should  "not.exist"

    cy.get("._modal-slot").within ($modal) ->
      expect($modal).to.contain "scored by Joe Camel"
      expectTotalWeight "100"
      cy.contains("Save and Close").should "have.attr", "disabled"

    setWeight "Jedi+deadliness+Joe Camel", "30"
    expectTotalWeight "130"
    cy.contains("Save and Close").should "have.attr", "disabled"
    setWeight "Jedi+deadliness+Joe User", "30"
    expectTotalWeight "100"
    cy.contains("Save and Close").should "not.have.attr", "disabled"
    cy.el("submit-modal").click()
    cy.slot("jedi+darkness_rating+formula")
      .should "contain", "30"
      .and "contain", "40"
      .and "not.contain", "100"

    cy.main_slot().should "contain", "WikiRating"


  specify.only "Formula metric formula", =>
    cy.visit "Jedi+friendliness+formula"
    cy.slot "jedi+friendliness+formula"
      .find(".card-menu > a").click(force: true)

    cy.contains("a", "add metric", timeout: 15000)
      .click()
    cy.contains("button", "More Filters")
      .click()
    cy.contains("a", "Keyword")
      .click(force: true)
    cy.get("[name='filter[name]']")
      .clear()
      .type("multi{enter}")
    cy.get("._search-checkbox-list")
      .should("contain", "small multi")
      .should("contain", "big multi")
    cy.get("input[name='Joe User+small multi']").click()
    cy.get("._add-selected").click()
    cy.contains "M0"
    cy.contains "M1"





