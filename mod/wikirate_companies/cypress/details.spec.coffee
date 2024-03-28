describe "expanding details on company pages", ->
  specify "WikiRating", ->
    cy.visit "Death Star"

    # use filter to find darkness rating
    cy.get("._filters-button a").click()
    cy.get(".offcanvas").within () ->
      cy.contains("Metric Name").click()
      cy.get("[name='filter[metric_name]']").type("darkness{enter}")
    cy.get(".offcanvas-header .btn-close").click()

    # filter works
    cy.root().should "not.contain", "deadliness"

    # expand details
    cy.contains("darkness rating").click()

    cy.contains "deadliness"
    cy.contains "disturbance"

    # expand details of first score
    cy.get(".accordion-item:first-child .range-value").contains("60.0%").click()
    cy.get(".accordion-body").should("contain", "answer").and("contain", "100")
