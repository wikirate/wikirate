describe Card::Set::Right::ContributedMetrics do

  before do
    login_as "joe_user" 
    metrics = Card.search :type_id=>Card::MetricID, :limit=>4
    metrics.each  do |metric|
      vote_count_card = Card[metric.name+"+*vote_count"]
      if !vote_count_card
        Card::Auth.as_bot do
          vote_count_card = Card.create!(:name=>metric.name+"+*vote_count")
        end
      end
      vote_count_card.vote_up
    end
    
    @user_card = Card["joe_user"]
    @c_card = @user_card.fetch(:trait=>:contributed_metrics)
  end
  describe ".contribution_counts" do
    it "returns correct contribution count" do
      expect(@c_card.contribution_count).to eq(4)
    end
  end
  describe "header view" do
    it "returns correct contribution analysis" do
      html = @c_card.format.render_header
      expect(html).to have_tag("i",:with=>{:class=>"fa fa-bar-chart-o"})

    end
  end
  
end