
describe Card::Set::Right::RelatedArticles do
  before do
    login_as 'joe_user'
    @sample_company = get_a_sample_company
    @sample_topic = get_a_sample_topic
    @sample_analysis = get_a_sample_analysis
    @sample_claim = get_a_sample_claim
    @related_article_card = @sample_claim.fetch trait: :related_articles
  end

  describe 'core views' do
    it 'shows cited article and uncited article' do
      # one claim
      # 2 analysis
      # 1 cited in article
      # 1 non cited in article
      new_company  = Card.create name: 'test_company',
                                 type_id: Card::WikirateCompanyID
      new_topic    = Card.create name: 'test_topic',
                                 type_id: Card::WikirateTopicID
      new_analysis = Card.create name: "#{new_company.name}+#{new_topic.name}",
                                 type_id: Card::WikirateAnalysisID
      new_article  = Card.create name: "#{new_company.name}+#{new_topic.name}"\
                                       "+#{Card[:wikirate_article].name}",
                                 type_id: Card::BasicID,
                                 content: 'Today is Wednesday.'

      claim_card = create_claim(
        'whateverclaim',
        '+company' => {
          content: "[[#{new_company.name}]]\r\n[[#{@sample_company.name}]]"
        },
        '+topic' => {
          content: "[[#{new_topic.name}]]\r\n[[#{@sample_topic.name}]]"
        }
      )

      sample_article = @sample_analysis.fetch trait: :wikirate_article, new: {}
      sample_article.content =
        "I need some kitkat.#{claim_card.default_citation}"
      sample_article.save

      test_company_force_analysis = Card.create :name=>"#{new_company.name}+#{@sample_topic.name}",:type_id=>Card::WikirateAnalysisID
      test_company_force_article = Card.create :name=>"#{new_company.name}+#{@sample_topic.name}+#{Card[:wikirate_article].name}",:type_id=>Card::BasicID,:content=>"Today is Friday."

      death_star_test_company_analysis = Card.create :name=>"#{@sample_company.name}+#{new_topic.name}",:type_id=>Card::WikirateAnalysisID
      death_star_test_company_article = Card.create :name=>"#{@sample_company.name}+#{new_topic.name}+#{Card[:wikirate_article].name}",:type_id=>Card::BasicID,:content=>"Today is Friday."

      related_article_card = claim_card.fetch :trait=>:related_articles
      html = related_article_card.format(:format=>:html)._render_core

      expect(html).to have_tag("div",:with=>{:class=>"related-articles cited-articles"}) do
        with_tag "h3",:text=>"Overviews that cite this Claim"
        with_tag "div", :with=>{:class=>"analysis-link"}
        with_tag "a", :with=>{ :href=>"/Death_Star+Force" } do
          with_tag "span", :text=>"Death Star"
          with_tag "span", :text=>"Force"
        end
      end
      expect(html).to have_tag("div",:with=>{:class=>"related-articles uncited-articles"}) do
        # with_tag "h3",:text=>"Articles that <em>could</em> cite this Claim"
        with_tag "div", :with=>{:class=>"analysis-link"} do
          with_tag "a", :with=>{ :href=>"/test_company+test_topic" } do
            with_tag "span", :text=>"test_company"
            with_tag "span", :text=>"test_topic"
            with_tag "span", :with=>{ :class=>"claim-next-action" } do
              with_tag "a", :with=>{ :href=>"/test_company+test_topic?citable=whateverclaim&edit_article=true" }, :text=>"Cite!"
            end
          end
        end

        with_tag "div", :with=>{:class=>"analysis-link"} do
          with_tag "a", :with=>{ :href=>"/test_company+Force" } do
            with_tag "span", :text=>"test_company"
            with_tag "span", :text=>"Force"
            with_tag "span", :with=>{ :class=>"claim-next-action" } do
              with_tag "a", :with=>{ :href=>"/test_company+Force?citable=whateverclaim&edit_article=true" }, :text=>"Cite!"
            end
          end
        end

        with_tag "div", :with=>{:class=>"analysis-link"} do
          with_tag "a", :with=>{ :href=>"/Death_Star+test_topic" } do
            with_tag "span", :text=>"Death Star"
            with_tag "span", :text=>"test_topic"
            with_tag "span", :with=>{ :class=>"claim-next-action" } do
              with_tag "a", :with=>{ :href=>"/Death_Star+test_topic?citable=whateverclaim&edit_article=true" }, :text=>"Cite!"
            end
          end
        end
      end
    end
    context "when no related overviews" do
      it "shows no related overviewss" do
        claim_card = create_claim "whateverclaim",{}
        related_article_card = Card.fetch claim_card.name+"+related overviews"
        html = related_article_card.format(:format=>:html)._render_core
        expected_html = %{<h3 class="no-article no-overview">No related Overviews yet.</h3>} + claim_card.format.render_tip
        expect(html.squish).to eq(expected_html.squish)
      end
    end
  end
  it "returns citation link" do
    citation = {:citable=>@related_article_card.cardname.trunk_name}
    html = @related_article_card.format(:format=>:html).citation_link @sample_analysis.to_name
    expect(html).to have_tag "span",:with=>{:class=>"claim-next-action"},:text=>"[[/#{@sample_analysis.to_name.url_key}?#{citation.to_param}&edit_article=true | Cite!]]"
    # expect(html).to include(%{<span class=\"claim-next-action\">[[/#{@sample_analysis.to_name.url_key}?#{citation.to_param}&edit_article=true | Cite!]]</span>})
  end
  context "when calling analysis_links" do

    it "show the view without the citation name" do
      html = @related_article_card.format(:format=>:html).analysis_links @sample_analysis.name,true

      expect(html).to have_tag("span",:with=>{:class=>"company"},:text=>"#{@sample_analysis.name.to_name.trunk_name}")
      expect(html).to have_tag("span",:with=>{:class=>"topic"},:text=>"#{@sample_analysis.name.to_name.tag_name}")
      expect(html).to have_tag("a",:with=>{:class=>"known-card", :href=>"/#{@sample_analysis.name.to_name.url_key}"})

    end
    it "shows the view with the citation name" do
      html = @related_article_card.format(:format=>:html).analysis_links @sample_analysis.name,false
      citation_html = @related_article_card.format(:format=>:html).citation_link @sample_analysis.name.to_name

      expect(html).to have_tag("span",:with=>{:class=>"company"},:text=>"#{@sample_analysis.name.to_name.trunk_name}")
      expect(html).to have_tag("span",:with=>{:class=>"topic"},:text=>"#{@sample_analysis.name.to_name.tag_name}")
      expect(html).to have_tag("a",:with=>{:class=>"known-card", :href=>"/#{@sample_analysis.name.to_name.url_key}"})

      expect(html).to include(@related_article_card.format(:format=>:html).process_content(citation_html))
    end
  end

end
