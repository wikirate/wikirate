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
      binding.pry
      html = @sample_analysis.format.render_core
      puts "hello"
    end
  end

end