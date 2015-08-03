describe Card::Set::Right::ContributedSources do

  before do
    login_as "joe_user" 
    sources = Card.search :type_id=>Card::SourceID, :limit=>5
    sources.each  do |source|
      vote_count_card = Card[source.name+"+*vote_count"]
      if !vote_count_card
        Card::Auth.as_bot do
          vote_count_card = Card.create!(:name=>source.name+"+*vote_count")
        end
      end
      vote_count_card.vote_up
    end
    
    @user_card = Card["joe_user"]
    @c_card = @user_card.fetch(:trait=>:contributed_sources)
  end
  describe ".contribution_counts" do
    it "returns correct contribution count" do
      expect(@c_card.contribution_count).to eq(5)
    end
  end
  describe "header view" do
    it "returns correct contribution analysis" do
      html = @c_card.format.render_header
      expect(html).to have_tag("i",:with=>{:class=>"fa fa-globe"})

    end
  end
  
end