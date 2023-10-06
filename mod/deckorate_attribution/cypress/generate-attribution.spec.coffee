describe "Attribution Generator - Dataset", ->
  before ->
    cy.login()
    cy.visit("http://localhost:5002/Evil_Dataset")
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
    cy.contains("Wikirate.org, 'Evil Dataset' (http://localhost:5002/~3644) by Decko Bot, licensed under CC BY 4.0 (https://creativecommons.org/licenses/by/4.0)")
  it "generates attribution for HTML.", ->
    cy.get(".tab-li-html").click()
    cy.contains('<a href="https://wikirate.org" target="_blank">Wikirate.org</a>, \'<a href="http://localhost:5002/~3644" target="_blank">Evil Dataset</a>\' by <a href="http://localhost:5002/~1" target="_blank">Decko Bot</a>, licensed under <a href="https://creativecommons.org/licenses/by/4.0" target="_blank">CC BY 4.0</a>')
    # cy.contains("Copy").click() #TODO: assert feedback

describe "Attribution Generator - Metric", ->
  before ->
    cy.login()
    cy.visit("http://localhost:5002/Jedi+disturbances_in_the_Force")
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
  before ->
    cy.login()
    cy.visit("http://localhost:5002/Answers")
  it "finds the attribution generator icon.", ->
    deathStar = cy.get("span.card-title[title='Death Star']")
    dropdown = cy.get("div.bar-menu-button[data-bs-toggle='dropdown']").first().invoke("show")
    dropdown.click()
            .get('a.slotter[data-slotter-mode="modal"][size="large"][data-remote="true"]').eq(3)
            # .should("be.visible")  TODO: This fails
            # .click()
