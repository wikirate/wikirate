describe Card::Set::Right::MyContributions do
  before do
    @user_card = Card["joe_user"]
    @user_contribution = @user_card.fetch :trait=>:my_contributions
  end
  describe ".section" do
    it "returns count,name and contribution_card_name of contributions for different types of card" do

      result = @user_contribution.sections
      expect(result).to include([0, Card[:metric].name, "Joe_User+#{Card[:contributed_metrics].cardname.url_key}"])
      expect(result).to include([0, Card[:claim].name, "Joe_User+#{Card[:contributed_claims].cardname.url_key}"])
      expect(result).to include([0, Card[:source].name, "Joe_User+#{Card[:contributed_sources].cardname.url_key}"])
      expect(result).to include([0, Card[:wikirate_article].name, "Joe_User+#{Card[:contributed_analysis].cardname.url_key}"])
      expect(result).to include([0, Card[:campaign].name, "Joe_User+#{Card[:contributed_campaigns].cardname.url_key}"])
    end
  end
  describe "core view" do
    it "render the customized view " do
      html = @user_contribution.format.render_core
      expect(html).to have_tag "div",:with=>{:id=>"Joe_User+contributed_sources"} do
        with_tag "span",:with=>{:class=>"card-title"},:text=>"Source"
        with_tag "span",:with=>{:class=>"badge"},:text=>"0"
      end

    end
  end
  describe "contribution_counts view" do
    it "render the counts for different contribution" do
      html = @user_contribution.format.render_contribution_counts
      expect(html).to have_tag "a",:with=>{:class=>"item",:href=>"#Joe_User+#{Card[:contributed_metrics].cardname.url_key}"} do
        with_tag "span",:with=>{:class=>"metric"},:text=>"0"
        with_tag "p", :with=>{:class=>"legend"},:text=>"Metric"
      end
      expect(html).to have_tag "a",:with=>{:class=>"item",:href=>"#Joe_User+#{Card[:contributed_claims].cardname.url_key}"} do
        with_tag "span",:with=>{:class=>"note"},:text=>"0"
        with_tag "p", :with=>{:class=>"legend"},:text=>"Note"
      end
      expect(html).to have_tag "a",:with=>{:class=>"item",:href=>"#Joe_User+#{Card[:contributed_sources].cardname.url_key}"} do
        with_tag "span",:with=>{:class=>"source"},:text=>"0"
        with_tag "p", :with=>{:class=>"legend"},:text=>"Source"
      end
      expect(html).to have_tag "a",:with=>{:class=>"item",:href=>"#Joe_User+#{Card[:contributed_analysis].cardname.url_key}"} do
        with_tag "span",:with=>{:class=>"overview"},:text=>"0"
        with_tag "p", :with=>{:class=>"legend"},:text=>"Overview"
      end
      expect(html).to have_tag "a",:with=>{:class=>"item",:href=>"#Joe_User+contributed_campaigns"} do
        with_tag "span",:with=>{:class=>"campaign"},:text=>"0"
        with_tag "p", :with=>{:class=>"legend"},:text=>"Campaign"
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
