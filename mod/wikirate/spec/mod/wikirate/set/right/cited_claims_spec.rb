# -*- encoding : utf-8 -*-

describe Card::Set::Right::CitedClaims do
  before do
    login_as 'joe_user' 
    @sample_company = get_a_sample_company
    @sample_topic = get_a_sample_topic
    @sample_analysis = get_a_sample_analysis
    @sample_claim = get_a_sample_claim

  end
  describe "core view" do
    it do
      #create claim related to analysis but not cited      

      claim_card = create_claim "whateverclaim",{"+company"=>{:content=>"[[#{@sample_company.name}]]"},"+topic"=>{:content=>"[[#{@sample_topic.name}]]"}}      
      sample_article = Card[@sample_analysis.name+"+#{Card[:wikirate_article].name}"]
      sample_article.content = "I need some chewing gum.#{claim_card.default_citation}"
      sample_article.save
      
      html = @sample_analysis.format.render_core
      expect(html.squish).to include(%{<span class="cited-claim-number">1</span> <div id="whateverclaim"})
      expect(html.squish).to include(%{<i class=\"fa fa-clipboard claim-clipboard\" id=\"copy-button\" title=\"copy claim citation to clipboard\" data-clipboard-text=\"Death Star uses dark side of the Force {{Death Star uses dark side of the Force|cite}}\"></i> <div id=\"Death_Star_uses_dark_side_of_the_Force\"})

    end
  end

end