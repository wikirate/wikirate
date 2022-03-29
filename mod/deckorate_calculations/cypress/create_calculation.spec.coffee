describe "metric creation", ->
  before ->
    cy.login()

  beforeEach ->
    cy.visit("new/Metric")

  specify "metric type: formula", ->
    cy.contains("Formula").click()

