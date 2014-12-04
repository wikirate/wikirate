
describe Card::Set::Right::RelatedArticles do
  before do
    login_as 'joe_user' 
    @sample_company = get_a_sample_company
    @sample_topic = get_a_sample_topic
    @sample_analysis = get_a_sample_analysis
    @sample_claim = get_a_sample_claim
    @related_article_card = Card.fetch @sample_claim.name+"+related article"
  end
  describe "core views" do
    it "shows cited article and uncited article" do
      # one claim
      # 2 analysis
      # 1 cited in article
      # 1 non cited in article
      new_company = Card.create :name=>"test_company",:type_id=>Card::WikirateCompanyID
      new_topic = Card.create :name=>"test_topic",:type_id=>Card::WikirateTopicID
      new_analysis = Card.create :name=>"#{new_company.name}+#{new_topic.name}",:type_id=>Card::WikirateAnalysisID
      new_article = Card.create :name=>"#{new_company.name}+#{new_topic.name}+#{Card[:wikirate_article].name}",:type_id=>Card::BasicID,:content=>"Today is Wednesday."

      claim_card = create_claim "whateverclaim",{"+company"=>{:content=>"[[#{new_company.name}]]\r\n[[#{@sample_company.name}]]"},"+topic"=>{:content=>"[[#{new_topic.name}]]\r\n[[#{@sample_topic.name}]]"}}      

      sample_article = Card[@sample_analysis.name+"+#{Card[:wikirate_article].name}"]
      sample_article.content = "I need some kitkat.#{claim_card.default_citation}"
      sample_article.save

      related_article_card = Card.fetch claim_card.name+"+related article"
      html = related_article_card.format(:format=>:html)._render_core
      
      expected_html = %{<div class="related-articles cited-articles">
          <h3>Articles that cite this Claim</h3>
          <ul><li><div class="analysis-link"><a class="known-card" href="/Death_Star+Force"><span class="company">Death Star</span><span class="topic">Force</span></a> </div></ul>
        </div>

        <div class="related-articles uncited-articles">
          <h3>Articles that <em>could</em> cite this Claim</h3>
          <ul><li><div class="analysis-link"><a class="known-card" href="/test_company+test_topic"><span class="company">test_company</span><span class="topic">test_topic</span></a>  <span class="claim-next-action"><a class="internal-link" href="/test_company+test_topic?citable=whateverclaim&edit_article=true">Cite!</a></span> </div>
              <li><div class="analysis-link"><a class="known-card" href="/test_company+Force"><span class="company">test_company</span><span class="topic">Force</span></a>  <span class="claim-next-action"><a class="internal-link" href="/test_company+Force?citable=whateverclaim&edit_article=true">Cite!</a></span> </div>
              <li><div class="analysis-link"><a class="known-card" href="/Death_Star+test_topic"><span class="company">Death Star</span><span class="topic">test_topic</span></a>  <span class="claim-next-action"><a class="internal-link" href="/Death_Star+test_topic?citable=whateverclaim&edit_article=true">Cite!</a></span> </div></ul>
        </div>}
      expect(html.squish).to eq(expected_html.squish)
    end
    context "when no related article" do
      it "shows no related articles" do 
        claim_card = create_claim "whateverclaim",{}
        related_article_card = Card.fetch claim_card.name+"+related article"
        html = related_article_card.format(:format=>:html)._render_core
        expected_html = %{<h3 class="no-article">No related Articles yet.</h3>} + claim_card.format.render_tips
        expect(html.squish).to  eq(expected_html.squish)
      end
    end
  end
  it "returns citation link" do 
    citation = {:citable=>@related_article_card.cardname.trunk_name}
    html = @related_article_card.format(:format=>:html).citation_link @sample_analysis.to_name
    expect(html).to include(%{<span class=\"claim-next-action\">[[/#{@sample_analysis.to_name.url_key}?#{citation.to_param}&edit_article=true | Cite!]]</span>})
  end
  context "when calling analysis_links" do
   
    it "show the view without the citation name" do
      html = @related_article_card.format(:format=>:html).analysis_links @sample_analysis.name,true
      expect(html).to include(%{<span class="company">#{@sample_analysis.name.to_name.trunk_name}</span>})
      expect(html).to include(%{<span class="topic">#{  @sample_analysis.name.to_name.tag_name  }</span>})
      expect(html).to include(%{<a class="known-card" href="/#{@sample_analysis.name.to_name.url_key}">})
    end
    it "shows the view with the citation name" do
      html = @related_article_card.format(:format=>:html).analysis_links @sample_analysis.name,false
      citation_html = @related_article_card.format(:format=>:html).citation_link @sample_analysis.name.to_name
      expect(html).to include(%{<span class="company">#{@sample_analysis.name.to_name.trunk_name}</span>})
      expect(html).to include(%{<span class="topic">#{  @sample_analysis.name.to_name.tag_name  }</span>})
      expect(html).to include(%{<a class="known-card" href="/#{@sample_analysis.name.to_name.url_key}">})
      expect(html).to include(@related_article_card.format(:format=>:html).process_content(citation_html))
    end
  end

end