
describe Card::Set::Right::RelatedArticles do
  before do
    login_as 'joe_user' 
  end
  it "returns citation link" do 
    sample_company = get_a_sample_company
    sample_topic = get_a_sample_topic
    sample_analysis = get_a_sample_analysis
    
    claim = get_a_sample_claim
    related_article_card = Card.fetch claim.name+"+related article"

    citation = {:citable=>related_article_card.cardname.trunk_name}

    html = related_article_card.format(:format=>:html).citation_link sample_analysis.to_name
    expect(html).to include(%{<span class=\"claim-next-action\">[[/#{sample_analysis.to_name.url_key}?#{citation.to_param}&edit_article=true | Cite!]]</span>})


  end
  context "when calling analysis_links" do
    before do
      @claim_card = get_a_sample_claim
      @related_article_card = Card.fetch claim.name+"+related article"
    end
    it "does not show the citation name" do
      
      html = related_article_card.format(:format=>:html).citation_link sample_analysis.name,true
      # company_name = %{<span class="company">#{analysis_name.to_name.trunk_name}</span>}
      # topic_name   = %{<span class="topic">#{  analysis_name.to_name.tag_name  }</span>}
      # simple_link  = %{[[#{analysis_name}|#{company_name}#{topic_name}]]}
      
      # citation_link = cited ? '' : citation_link( analysis_name.to_name )
          
      # process_content %{<div class=\"analysis-link\">#{simple_link} #{citation_link}</div>}

      #<div class=\"analysis-link\"><a class=\"known-card\" href=\"/Apple+Natural_Resource_Use\"><span class=\"company\">Apple</span><span class=\"topic\">Natural Resource Use</span></a>  <span class=\"claim-next-action\"><a class=\"internal-link\" href=\"/Apple+Natural_Resource_Use?citable=Lidl+Accused+of+Spying+on+Workers&edit_article=true\">Cite!</a></span> </div>
    end
  end

end