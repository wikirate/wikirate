RSpec.describe Card::Set::Right::RelatedArticles do
  let :analysis_card do
    @sample_analysis = sample_analysis
  end

  let :topic do
    sample_topic.name
  end

  let :company do
    sample_company.name
  end

  before do
    login_as "joe_user"
    analysis_card
    @sample_claim = sample_note
    @related_article_card = @sample_claim.fetch trait: :related_articles
  end

  describe "core views" do
    it "shows cited article and uncited article" do
      # one claim
      # 2 analysis
      # 1 cited in article
      # 1 non cited in article
      new_company =
        Card.create name: "test_company", type_id: Card::WikirateCompanyID
      new_topic =
        Card.create name: "test_topic", type_id: Card::WikirateTopicID
      # new_analysis =
      Card.create name: "#{new_company.name}+#{new_topic.name}",
                  type_id: Card::WikirateAnalysisID
      # new_article  =
      Card.create name: [new_company.name, new_topic.name, :overview],
                  type_id: Card::BasicID,
                  content: "Today is Wednesday."

      claim_card = create_claim(
        "whateverclaim",
        "+company" => { content: [new_company.name, company] },
        "+topic" => { content: [new_topic.name, topic] }
      )

      sample_article = @sample_analysis.fetch trait: :overview, new: {}
      sample_article.content =
        "I need some kitkat.#{claim_card.default_citation}"
      sample_article.save

      Card.create name: "#{new_company.name}+#{topic}",
                  type_id: Card::WikirateAnalysisID

      Card.create name: "#{new_company.name}+#{topic}+"\
                        "#{Card[:overview].name}",
                  type_id: Card::BasicID,
                  content: "Today is Friday."

      Card.create name: "#{company}+#{new_topic.name}",
                  type_id: Card::WikirateAnalysisID

      Card.create name: "#{company}+#{new_topic.name}+"\
                        "#{Card[:overview].name}",
                  type_id: Card::BasicID,
                  content: "Today is Friday."

      related_article_card = claim_card.fetch trait: :related_articles
      html = related_article_card.format(format: :html)._render_core

      divtext = "related-articles cited-articles"
      expect(html).to have_tag("div", with: { class: divtext }) do
        with_tag "h4", text: "Overviews that cite this Claim"
        with_tag "div", with: { class: "analysis-link" }
        with_tag "a", with: { href: "/Death_Star+Force" } do
          with_tag "span", text: "Death Star"
          with_tag "span", text: "Force"
        end
      end

      claim_action_link = "/test_company+test_topic?"\
                          "citable=whateverclaim&edit_article=true"

      expect(html).to have_tag("div.related-articles.uncited-articles") do
        # with_tag 'h3', text: 'Articles that <em>could</em> cite this Claim'
        with_tag "div", with: { class: "analysis-link" } do
          with_tag "a", with: { href: "/test_company+test_topic" } do
            with_tag "span", text: "test_company"
            with_tag "span", text: "test_topic"
          end
          with_tag "span", with: { class: "claim-next-action" } do
            with_tag "a", with: { href: claim_action_link }, text: "Cite!"
          end
        end

        with_tag "div", with: { class: "analysis-link" } do
          with_tag "a", with: { href: "/test_company+Force" } do
            with_tag "span", text: "test_company"
            with_tag "span", text: "Force"
          end
          with_tag "span", with: { class: "claim-next-action" } do
            with_tag "a", with: { href: "/test_company+Force?"\
                                        "citable=whateverclaim&"\
                                        "edit_article=true" }, text: "Cite!"
          end
        end

        with_tag "div", with: { class: "analysis-link" } do
          with_tag "a", with: { href: "/Death_Star+test_topic" } do
            with_tag "span", text: "Death Star"
            with_tag "span", text: "test_topic"
          end
          with_tag "span", with: { class: "claim-next-action" } do
            with_tag "a", with: { href: "/Death_Star+test_topic?"\
                                        "citable=whateverclaim"\
                                        "&edit_article=true" }, text: "Cite!"
          end
        end
      end
    end

    context "when no related overviews" do
      it "shows no related overviewss" do
        claim_card = create_claim "whateverclaim", {}
        related_article_card = claim_card.fetch trait: :related_articles
        html = related_article_card.format(format: :html)._render_core
        expected_html = '<h4 class="no-article no-overview">'\
                        "No related Overviews yet.</h4>" +
                        claim_card.format.render_tip
        expect(html.squish).to eq(expected_html.squish)
      end
    end
  end

  context "when calling analysis_links" do
    it "show the view without the citation name" do
      format = @related_article_card.format(format: :html)
      html = format.analysis_links @sample_analysis.name, true

      expect(html).to have_tag("span.company", text: @sample_analysis.name.to_name.trunk_name)
      expect(html).to have_tag("span.topic",   text: @sample_analysis.name.to_name.tag_name)
      expect(html).to have_tag("a.known-card", with: { href: "/#{@sample_analysis.name.to_name.url_key}" })
    end

    it "shows the view with the citation name" do
      format = @related_article_card.format(format: :html)
      html = format.analysis_links @sample_analysis.name, false
      citation_html = format.citation_link @sample_analysis.name.to_name

      expect(html).to have_tag("span.company", text: @sample_analysis.name.to_name.trunk_name)
      expect(html).to have_tag("span.topic",   text: @sample_analysis.name.to_name.tag_name)
      expect(html).to have_tag("a.known-card", with: { href: "/#{@sample_analysis.name.to_name.url_key}" })

      expect(html).to include(format.process_content(citation_html))
    end
  end
end
