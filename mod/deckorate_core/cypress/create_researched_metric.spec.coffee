describe "researched metric creation", ->
  beforeEach ->
    cy.login("joe@camel.com")
    cy.visit("new/Metric")


  specify "metric type: Research", ->
    cy.get(".box").within -> cy.contains("Researched").click()
    cy.get(".RIGHT-Xtitle .d0-card-content").type("MyResearch")

    cy.contains("Submit").scrollIntoView().click()

    # go to details tab
    cy.contains("Details").click()
    cy.get(".RIGHT-Xmetric_type .d0-card-content").should "contain", "Researched"


  specify "metric type: Relationship", ->
    cy.get(".box").within ->
      cy.contains("Relationship").click()

    cy.get(".RIGHT-Xtitle .d0-card-content").type("owner of")
    cy.get(".RIGHT-inverse_title .d0-card-content").type("owned by")

    cy.get(".RIGHT-value_type input[type=radio]").check("Number")

    cy.contains("Submit").scrollIntoView().click()

    # go to details tab
    cy.contains("Details").click()

    hasProperty = (prop, label, value)->
      cy.get prop
        .should "contain", label
        .should "contain", value

    cy.get(".metric-properties").within ->
      hasProperty ".designer-property", "Designed by", "Joe Camel"
      hasProperty ".RIGHT-Xmetric_type", "Metric Type", "Relationship"
      hasProperty ".RIGHT-value_type", "Value Type", "Number"
      hasProperty ".inverse-property", "Inverse Metric", "owned by"

