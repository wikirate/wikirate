describe "expanding details on company pages", ->
  specify "WikiRating", ->
    cy.visit "Death Star"

    # use filter to find darkness rating
    cy.get("._filter-container [name='filter[metric_name]']")
      .type("darkness{enter}")

    # filter works
    cy.root().should "not.contain", "deadliness"

    #expands details
    cy.contains("darkness rating").click()

    cy.get(".details").within () ->
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
      cy.get("> div:visible .details-close-icon").click()
      cy.contains "Scored Metric"
      cy.get("> div:visible").should "not.contain", "disturbance"
      cy.get("> div:visible").should "not.contain", "Sources"

      # closes score
      cy.get("> div:visible .details-close-icon").click()
      cy.contains "deadliness"
      cy.contains "disturbance"

    # refreshes filter
    cy.get(".left-col").within () ->
      cy.get(".fa-sync-alt").click()
      cy.contains "Industry"

    # details are still visible (even after filter results have changed)
    cy.get(".details").within () ->
      cy.contains "deadliness"

      # closes details
      cy.get(".details-close-icon").click()

    # details tab visible again
    cy.contains("Integrations")
