describe 'edit formula', ->
  before -> cy.login()

  # specify "edit variable"


  specify.only "Formula metric formula", ->
    cy.visit "Jedi+friendliness+formula"
    cy.slot "jedi+friendliness+formula"
      .find(".card-menu > a.edit-link").click(force: true)
    cy.contains("a", "Add Variable", timeout: 15000)
      .click()
    cy.get("._filter-container [name='filter[name]']")
      .type("multi{enter}")
    cy.get("._search-checkbox-list")
      .should("contain", "small multi")
      .should("contain", "big multi")
    cy.get("input#Joe_User_small_multi").click()
    cy.get("._add-selected").click()
    cy.contains "m1"
