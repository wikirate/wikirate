toPhase = (phase) ->
  cy.get(".tab-li-#{phase}_phase .nav-link").click()

describe "research page", ->
  specify "project journey", ->
    cy.login "sample@user.com", "sample_pass"
    cy.visit "Jedi+cost_of_planets_destroyed+Death_Star+1977"
    cy.get("._research_answer_button").click()

    toPhase "answer"

    crumb = cy.get ".answer-breadcrumb"
    crumb.should "contain", "1977"
    crumb.should "contain", "Death Star"
    crumb.should "contain", "cost of planets destroyed"
    crumb.should "not.contain", "Jedi"

    cy.get("._edit-answer-button").click()

    cy.editor("value").find(".short-input").clear().type "404"

    toPhase "source"

    btn = cy.get "._add_source_modal_link"
    btn.should "contain", "Add new source"
    btn.click()

    existingSource = "https://thereaderwiki.com/en/Apple"
    cy.editor("file").find("input.d0-card-content").clear().type existingSource
    cy.editor("title").find("input.d0-card-content").focus() # move focus away

    alert = cy.get ".alert"
    alert.should "contain", "A source already exists for this url"

    alert.find("._copy_caught_source").click()
    cy.get("#_select_source").click()

    cy.editor("source").should "contain", "Apple"
    cy.editor("source").should "contain", "Star Wars"