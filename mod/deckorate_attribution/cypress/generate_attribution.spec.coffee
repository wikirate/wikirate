describe "Attribution Generator - Dataset", ->
  beforeEach ->
    cy.login()
    cy.visit("/Evil_Dataset")
    cy.contains("Evil Dataset")
    # show hidden icons
    attribution = cy.get("a.slotter").invoke('show')
    # click attribution icon
    attribution.contains("attribution").click()
    # generate attribution by clicking 'Save' button
    cy.get('button.submit-button').click();
  it "generates attribution for Rich Text.", ->
    cy.get(".tab-li-rich_text").click()
    cy.contains("Wikirate.org, 'Evil Dataset' by Decko Bot, licensed under CC BY 4.0")
  it "generates attribution for Plain Text.", ->
    cy.get(".tab-li-plain_text").click()
    cy.contains("Wikirate.org, 'Evil Dataset' by Decko Bot, licensed under CC BY 4.0")
  it "generates attribution for HTML.", ->
    cy.get(".tab-li-html").click()
    cy.contains("div", /<a\s+href="((?!localhost|ids).+?)"\s+target="_blank">(.+?)<\/a>/)

describe "Attribution Generator - Metric", ->
  beforeEach ->
    cy.login()
    cy.visit("/Jedi+disturbances_in_the_Force")
    cy.contains("disturbances in the Force")
    # show hidden icons
    attribution = cy.get("a.slotter").invoke("show")
    # click attribution icon
    attribution.contains("attribution").click()
    # generate attribution by clicking 'Save' button
    cy.get('button.submit-button').click();
  it "generates attribution for Rich Text.", ->
    cy.get(".tab-li-rich_text").click()
    cy.contains("Wikirate's community")
  it "generates attribution for Plain Text.", ->
    cy.get(".tab-li-plain_text").click()
    cy.contains("Wikirate's community")
  it "generates attribution for HTML.", ->
    cy.get(".tab-li-html").click()
    cy.contains("Wikirate's community")

describe "Attribution Generator - Answer Dashboard", ->
  beforeEach ->
    cy.login()
    cy.visit("http://localhost:5002/Answers")
  it "finds the attribution generator ic\"span.card-title[title='Death Star']\"on.", ->
    cy.get(".tree-button").first().click()
    dropdown = cy.get("div.bar-menu-button[data-bs-toggle='dropdown']").first().invoke("show")
    dropdown.click()
            .get('a.slotter[data-slotter-mode="modal"][size="large"][data-remote="true"]').eq(3)
            # .should("be.visible")  TODO: This fails
            # .click()
