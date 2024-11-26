describe "filtering on company pages", ->
  specify "topics tab", ->
    cy.visit "Death Star"

    # shows lots of answer before filtering
    cy.get(".tab-li-answer").click()
    cy.contains "Category"
    cy.contains "disturbances"

#    # go to topic tab
#    cy.contains("Topics").click()
#
#    # "Taming" topic present before filtering
#    cy.contains("Taming")
#    cy.get("._filter-container [name='filter[name]']")
#      .type("forc")
#
#    # Topic is now filtered out
#    cy.should "not.contain", "Taming"
#
#    # url bar is NOT updated with filter
#    cy.location("search").should "not.contain", "filter"
#
#    # click on a topic
#    cy.contains("Force").click()


#
#    # shows answer for metric tagged by topic
#    cy.contains "disturbances"
#    # ...but not for metric not tagged by topic
#    cy.should "not.contain", "Company Category"
#
#    # url bar is updated with filter
#    cy.location("search").should "contain", "filter"
#
#    # refreshes filter
#    cy.get(".left-col .fa-sync-alt").click()
#
#    # old results are back
#    cy.contains("Company Category")
#    cy.contains "disturbances"
