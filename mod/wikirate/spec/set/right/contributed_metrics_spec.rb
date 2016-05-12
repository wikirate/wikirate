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
      @user_card = Card["joe_user"]
      @c_card = @user_card.fetch(:trait=>:contributed_metrics)
    end
  end
  subject { Card["joe_user"].fetch(:trait=>:contributed_metrics) }

  describe ".contribution_counts" do
    it "returns correct contribution count" do
      expect(subject.contribution_count).to eq(5)
    end
  end
  describe "header view" do
    it "returns correct contribution analysis" do
      html = subject.format.render_header
      expect(html).to have_tag("i", :with=>{:class=>"fa fa-bar-chart-o"})

    end
  end
end
