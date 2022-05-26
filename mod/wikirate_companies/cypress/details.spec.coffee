describe "expanding details on company pages", ->
  specify "WikiRating", ->
    cy.visit "Death Star"

    # use filter to find darkness rating
    cy.get("._filters-button button").click()
    cy.get(".offcanvas").within () ->
      cy.contains("Metric").click()
      cy.get("[name='filter[metric_name]']").type("darkness{enter}")
    cy.get(".offcanvas-header .btn-close").click()

    # filter works
    cy.root().should "not.contain", "deadliness"

    #expands details
    cy.contains("darkness rating").click()

    cy.get(".details-content").within () ->
      cy.contains "deadliness"
      cy.contains "disturbance"
      cy.root().should "not.contain", "Death Star"

      # expands details of first score
      cy.get("tbody tr:first-child .range-value").contains("10").click()
      cy.root().should "not.contain", "Death Star"
      cy.contains "Scored Metric"
      cy.get("> div:visible").should "not.contain", "disturbance"
      cy.get("> div:visible").should "not.contain", "Sources"

      # expands details of raw value
      cy.get("> div:visible").contains("100").click()
      cy.root().should "not.contain", "Death Star"
      cy.contains "Sources"
      cy.contains "thereaderwiki.com"

      # closes raw value
      cy.get("> div:visible ._close-modal").click()
      cy.contains "Scored Metric"
      cy.get("> div:visible").should "not.contain", "disturbance"
      cy.get("> div:visible").should "not.contain", "Sources"

      # closes score
      cy.get("> div:visible ._close-modal").click()
      cy.contains "deadliness"
      cy.contains "disturbance"
