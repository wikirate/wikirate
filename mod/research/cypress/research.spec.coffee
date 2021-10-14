describe "research page", ->
  beforeEach ->
    cy.login "sample@user.com", "sample_pass"

  specify "project journey", ->
    cy.visit "Evil Project"
    cy.get(".tab-pane-wikirate_company").within ->
      cy.bar("Death_Star+Evil_Project").within ->
        cy.get(".research-answer-button").click()

    # project and company
    cy.get(".research-company")
      .should "contain", "Evil Project"
      .should "contain", "Death Star"

    # next metric
    cy.get(".research-metric-and-year")
      .should "contain", "disturbances in the Force"
      .within ->
        cy.get("[rel=next]").click()
    cy.get(".research-metric-and-year")
      .should "contain", "researched number 2"

    # click angle down to open company selector
    cy.get(".research-company [title='Select Company']").click()

    # choose Los Pollos Hermanos
    cy.bar("Los_Pollos_Hermanos+Evil_Project").within ->
      cy.get(".research-answer-button").click()

    # previous metric
    cy.get(".research-metric-and-year")
      .should "contain", "researched number 2"
      .within ->
        cy.get("[rel=prev]").click()
    cy.get(".research-metric-and-year")
      .should "contain", "disturbances in the Force"

    # choose year
    cy.get(".research-years").within ->
      cy.get(".research-year-list").should "not.contain", "2015"
      cy.scrollTo 0, 500
      cy.get(".page-link").contains("2").click()
      cy.get(".research-year-list").should "contain", "2015"
      cy.get("#year_2015").check()
      cy.get("#_select_year").click()



