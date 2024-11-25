describe "expanding details on company pages", ->
  specify "Rating", ->
    cy.visit "Death Star"

    # use filter to find darkness rating
    cy.get(".tab-li-answer").click()
    cy.get("._open-filters-button a").click()
    cy.get(".offcanvas").within () ->
      cy.get(".accordion-header").contains("Metric").click()
      cy.contains("Metric Keyword").click()
      cy.get("[name='filter[metric_keyword]']").type("darkness{enter}")
    cy.get(".offcanvas-header .btn-close").click()

    # filter works
    cy.root().should "not.contain", "deadliness"

    # expand details
    cy.contains("darkness rating").click()

    cy.contains "deadliness"
    cy.contains "disturbance"

    # expand details of score
    cy.get(".metric-tree-detail").contains("40%").click()
    cy.get(".tree-body").should("contain", "yes")
