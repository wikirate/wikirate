describe "research page", ->
  specify "project journey", ->
    cy.login "sample@user.com", "sample_pass"
    cy.visit "Jedi+cost_of_planets_destroyed+Death_Star+1977"
    cy.get("._research_answer_button").click()

    # year is already selected.  go to answer tab
    cy.get("#_select_year").click()

    # check the breadcrumb
    crumb = cy.get ".answer-breadcrumb"
    crumb.should "contain", "1977"
    crumb.should "contain", "Death Star"
    crumb.should "contain", "cost of planets destroyed"
    crumb.should "not.contain", "Jedi"


    # click on the source bar to go to source phase
    cy.get(".TYPE-source.bar").click()

    # click to add source
    btn = cy.get "._add_source_modal_link"
    btn.should "contain", "Add new source"
    btn.click()

    # try with a url that happens to exist
    existingSource = "https://thereaderwiki.com/en/Apple"
    cy.editor("file").find("input.d0-card-content").clear().type existingSource
    cy.editor("title").find("input.d0-card-content").focus() # move focus away

    # get prompted to use that existing source
    alert = cy.get ".alert"
    alert.should "contain", "A source already exists for this url"
    alert.find("._copy_caught_source").click()

    # choose to do so
    cy.get("#_select_source").click()

    # automatically in edit mode, source editor now cites two sources
    cy.editor("source")
      .should "contain", "Apple"
      .should "contain", "Star Wars"

    cy.editor("value").find(".short-input").clear().type "54321"

    cy.get("button").contains("Submit Answer").click()

    cy.get(".research-answer")
      .should "contain", "Edit Answer"
      .should "contain", "Apple"
      .should "contain", "Star Wars"
      .should "contain", "54,321"