toPhase = (phase) ->
  cy.get(".tab-li-#{phase}_phase .nav-link").click()

describe "research page", ->
  specify "project journey", ->
    cy.login "sample@user.com", "sample_pass"
    cy.visit "Evil Project"
    cy.get(".tab-li-company").click()
    cy.get(".tab-pane-company").within ->
      cy.bar("Death Star").within ->
        cy.get(".research-answer-button").click()

    # project and company
    cy.get(".research-company")
      .should "contain", "Evil Project"
      .should "contain", "Death Star"

    # next metric
    cy.get(".research-metric-and-year").should "contain", "disturbances in the Force"
      .within -> cy.get("[rel=next]").click()
    cy.get(".research-metric-and-year").should "contain", "researched number 2"

    # click angle down to open company selector
    cy.get(".research-company [title='Select Company']").click()

    # choose Los Pollos Hermanos
    cy.bar("Los Pollos Hermanos").within ->
      cy.get(".research-answer-button").click()

    # previous metric
    cy.get(".research-metric-and-year").should "contain", "researched number 2"
      .within -> cy.get("[rel=prev]").click()
    cy.get(".research-metric-and-year").should "contain", "disturbances in the Force"

    # choose year
    cy.get(".research-years").within ->
      cy.get("#research-year-list").within ->
        cy.get("#year_2015").should "not.be.visible"
        cy.get("#year_2020").check()
      cy.get("#_select_year").click()


    # remove default year and company filters
    cy.contains("Clear All").click()
#    cy.closeFilter "year"
#    cy.closeFilter "company_name"

    cy.get(".TYPE-source.box:first").click()
    cy.get("#_select_source").click()

    crumb = cy.get ".answer-breadcrumb"
    crumb.should "contain", "2020"
    crumb.should "contain", "Los Pollos Hermanos"
    crumb.should "contain", "disturbances in the Force"

    cy.editor("value").find("input[value=yes]").check()
    cy.editor("source").should "contain", "Opera"

    # forget to submit, try to go to a new question
    toPhase "question"
    cy.get(".research-metric-and-year [rel=next]").click()
    cy.get(".modal-body").within ->
      cy.get(".alert").should "contain", "Editing in progress"
      cy.wait 2000
      cy.get("._dont_leave").click()

    toPhase "answer"
    cy.get("button").contains("Submit Answer").click()
    cy.get(".research-answer").should "contain", "Edit Answer"
    cy.get(".research-answer ._next-question-button").click()
    cy.get(".research-metric-and-year").should "contain", "researched number 2"
