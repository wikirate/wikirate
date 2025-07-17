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
#    # "Wikirate ESG Topics+Social" topic present before filtering
#    cy.contains("Wikirate ESG Topics+Social")
#    cy.get("._filter-container [name='filter[name]']")
#      .type("forc")
#
#    # Topic is now filtered out
#    cy.should "not.contain", "Wikirate ESG Topics+Social"
#
#    # url bar is NOT updated with filter
#    cy.location("search").should "not.contain", "filter"
#
#    # click on a topic
#    cy.contains("Wikirate ESG Topics+Environment").click()


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
