# -*- encoding : utf-8 -*-

describe Card::Set::Right::CitedClaims do
  before do
    login_as 'joe_user'
    @sample_company = get_a_sample_company
    @sample_topic = get_a_sample_topic
    @sample_analysis = get_a_sample_analysis
    @sample_claim = get_a_sample_note

  end
  describe "core view" do
    it do
      #create claim related to analysis but not cited

      claim_card = create_claim "whateverclaim",{"+company"=>{:content=>"[[#{@sample_company.name}]]"},"+topic"=>{:content=>"[[#{@sample_topic.name}]]"}}
      sample_article = @sample_analysis.fetch :trait=>:overview, :new=>{}
      sample_article.content = "I need some chewing gum.#{claim_card.default_citation}"
      sample_article.save
      html = @sample_analysis.format.render_core
      expect(html).to have_tag("div", :with=>{:id=>"Death_Star+Force+Cited_Notes"}) do
        with_tag "div", :with=>{:class=>"search-result-list"} do
          with_tag "span",  :with=>{:class=>"cited-claim-number"}, :text=>"1"
          with_tag "div", :with=>{:id=>"whateverclaim", :class=>"SELF-whateverclaim"}
        end
      end
      expect(html).to have_tag("a[href='/Death_Star+Force?citable=Death_Star_uses_dark_side_of_the_Force&edit_article=true'][class='cite-button']",:text=>"Cite!")
    end
  end

end
