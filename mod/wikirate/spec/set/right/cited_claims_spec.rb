# -*- encoding : utf-8 -*-

describe Card::Set::Right::CitedClaims do
  before do
    login_as "joe_user"
    @sample_company = sample_company
    @sample_topic = sample_topic
    @sample_analysis = sample_analysis
    @sample_claim = sample_note
  end
  describe "core view" do
    # Cited Claims are temporarily removed.

    # it do
    #   # create claim related to analysis but not cited
    #
    #   claim_card =
    #     create_claim "whateverclaim",
    #                  "+company" => { content: "[[#{@sample_company.name}]]" },
    #                  "+topic" => { content: "[[#{@sample_topic.name}]]" }
    #   sample_article = @sample_analysis.fetch trait: :overview, new: {}
    #   sample_article.content =
    #     "I need some chewing gum.#{claim_card.default_citation}"
    #   sample_article.save
    #   html = @sample_analysis.format.render_core
    #   expect(html)
    #     .to have_tag("div", with: { id: "Death_Star+Force+Cited_Notes" }) do
    #     with_tag "div", with: { class: "search-result-list" } do
    #       with_tag "span",
    #                with: { class: "cited-claim-number" }, text: "1"
    #       with_tag "div",
    #                with: { id: "whateverclaim", class: "SELF-whateverclaim" }
    #     end
    #   end
    #   expect(html).to have_tag(
    #     "a[href='/Death_Star+Force?"\
    #     "citable=Death+Star+uses+dark+side+of+the+Force&edit_article=true']"\
    #     "[class='cite-button known-card']", text: "Cite!"
    #   )
    # end
  end
end
