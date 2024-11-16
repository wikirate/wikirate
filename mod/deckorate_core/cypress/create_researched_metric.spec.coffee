describe "researched metric creation", ->
  beforeEach ->
    cy.login("joe@camel.com")
    cy.visit("new/Metric")


  specify "metric type: Research", ->
    cy.get(".SELF-researched.box").within -> cy.contains("Researched").click()
    cy.get(".RIGHT-Xtitle .d0-card-content").type("MyResearch")

    cy.contains("Submit").scrollIntoView().click()

    cy.get(".header-middle")
      .should "contain", "Metric Type"
      .should "contain", "Researched"


  specify "metric type: Relation", ->
    cy.get(".SELF-relation.box").within ->
      cy.contains("Relation").click()

    cy.get(".RIGHT-Xtitle .d0-card-content").type("owner of")
    cy.get(".RIGHT-inverse_title .d0-card-content").type("owned by")

    cy.get(".RIGHT-value_type input[type=radio]").check("Number")

    cy.contains("Submit").scrollIntoView().click()

    cy.get(".header-middle")
    .should "contain", "Metric Type"
    .should "contain", "Relation"

    # go to details tab
    cy.contains("Details").click()

    hasProperty = (prop, label, value)->
      cy.get prop
        .should "contain", label
        .should "contain", value

    cy.get(".metric-properties").within ->
      hasProperty ".RIGHT-value_type", "Value Type", "Number"
      hasProperty ".inverse-property", "Inverse Metric", "owned by"

