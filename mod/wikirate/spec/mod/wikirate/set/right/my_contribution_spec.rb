describe Card::Set::Right::MyContributions do
  before do
    @user_card = Card["joe_user"]
    @user_contribution = @user_card.fetch :trait=>:my_contributions
  end
  describe ".section" do
    it "returns count,name and contribution_card_name of contributions for different types of card" do
      
      result = @user_contribution.sections
      expect(result).to include([0, "Metrics", "Joe_User+contributed_metrics"])
      expect(result).to include([0, "Claims", "Joe_User+contributed_claims"])
      expect(result).to include([0, "Sources", "Joe_User+contributed_sources"])
      expect(result).to include([0, "Articles", "Joe_User+contributed_analysis"])
      expect(result).to include([0, "Campaigns", "Joe_User+contributed_campaigns"])
    end
  end
  describe "core view" do
    it "render the customized view " do
      html = @user_contribution.format.render_core
      expect(html).to have_tag "div",:with=>{:id=>"Joe_User+contributed_sources"} do
        with_tag "span",:with=>{:class=>"card-title"},:text=>"Sources"
        with_tag "span",:with=>{:class=>"badge"},:text=>"0"
      end

    end
  end
  describe "contribution_counts view" do
    it "render the counts for different contribution" do
      html = @user_contribution.format.render_contribution_counts
      expect(html).to have_tag "a",:with=>{:class=>"item",:href=>"#Joe_User+contributed_metrics"} do
        with_tag "span",:with=>{:class=>"metrics"},:text=>"0"
        with_tag "p", :with=>{:class=>"legend"},:text=>"Metrics"
      end
      expect(html).to have_tag "a",:with=>{:class=>"item",:href=>"#Joe_User+contributed_claims"} do
        with_tag "span",:with=>{:class=>"claims"},:text=>"0"
        with_tag "p", :with=>{:class=>"legend"},:text=>"Claims"
      end
      expect(html).to have_tag "a",:with=>{:class=>"item",:href=>"#Joe_User+contributed_sources"} do
        with_tag "span",:with=>{:class=>"sources"},:text=>"0"
        with_tag "p", :with=>{:class=>"legend"},:text=>"Sources"
      end
      expect(html).to have_tag "a",:with=>{:class=>"item",:href=>"#Joe_User+contributed_analysis"} do
        with_tag "span",:with=>{:class=>"articles"},:text=>"0"
        with_tag "p", :with=>{:class=>"legend"},:text=>"Articles"
      end
      expect(html).to have_tag "a",:with=>{:class=>"item",:href=>"#Joe_User+contributed_campaigns"} do
        with_tag "span",:with=>{:class=>"campaigns"},:text=>"0"
        with_tag "p", :with=>{:class=>"legend"},:text=>"Campaigns"
      end
    end
  end
  describe "header view" do
    it "renders correct header view" do
      html = @user_contribution.format.render_header
      expect(html).to have_tag "div",:with=>{:class=>"card-header"} do
        with_tag "div",:with=>{:class=>"card-header-title"} do
          with_tag "span", :with=>{:class=>"card-title"}
          with_tag "div", :with=>{:class=>"counts"}
        end
      end
    end
  end
  
end