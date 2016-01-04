describe Card::Set::Right::ContributedAnalysis do

  before do
    @user_card = Card["joe_user"]

    analysis = get_a_sample_analysis

    article = Card[analysis.name].fetch :trait=>:overview,:new=>{}
    article.content = "One of my most productive days was throwing away 1000 lines of code."
    article.save!

    article1 = Card["Apple_Inc+Natural Resource Use"].fetch :trait=>:overview,:new=>{}
    article1.content = "When in doubt, use brute force."
    article1.save!
    @c_card = @user_card.fetch(:trait=>:contributed_analysis)
  end
  describe ".contribution_counts" do
    it "returns correct contribution count" do
      expect(@c_card.contribution_count).to eq(2)
    end
  end
  describe "header view" do
    it "returns correct contribution analysis" do
      html = @c_card.format.render_header
      expect(html).to have_tag("div",:with=>{:class=>"card-header-title"}) do
        with_tag "img",:with=>{:src=>Card.fetch('venn icon').format.render_source(:size=>:small)}
        with_tag "span",:witn=>{:class=>"badge"},:text=>"2"
      end

    end
  end

end