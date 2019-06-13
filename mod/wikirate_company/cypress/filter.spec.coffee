describe "filtering on company pages", ->
  specify "topics tab", ->
    cy.visit "Death Star"

    # shows lots of answers before filtering
    cy.contains "Victims"
    cy.contains "disturbances"

    # go to topic tab
    cy.get(".right-col").within () ->
      cy.contains("Topics").click()

      # "Taming" topic present before filtering
      cy.contains("Taming")
      cy.get("._filter-container [name='filter[name]']")
        .type("forc{enter}")

      # Topic is now filtered out
      cy.should "not.contain", "Taming"

      # url bar is NOT updated with filter
      cy.location("search").should "not.contain", "filter"

      # click on a topic
      cy.contains("Force").click()

    # shows answer for metric tagged by topic
    cy.contains "disturbances"
    # ...but not for metric not tagged by topic
    cy.should "not.contain", "Victims"

    # url bar is updated with filter
    cy.location("search").should "contain", "filter"

    # refreshes filter
    cy.get(".left-col .fa-refresh").click()

    # old results are back
    cy.contains("Victims")
    cy.contains "disturbances"
