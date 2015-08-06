describe Card::Set::Right::ContributedClaims do

  before do
    login_as "joe_user" 
    claims = Card.search :type_id=>Card::ClaimID, :limit=>3
    claims.each  do |claim|
      vote_count_card = Card[claim.name+"+*vote_count"]
      if !vote_count_card
        Card::Auth.as_bot do
          vote_count_card = Card.create!(:name=>claim.name+"+*vote_count")
        end
      end
      vote_count_card.vote_up
    end
    
    @user_card = Card["joe_user"]
    @c_card = @user_card.fetch(:trait=>:contributed_claims)
  end
  describe ".contribution_counts" do
    it "returns correct contribution count" do
      expect(@c_card.contribution_count).to eq(3)
    end
  end
  describe "header view" do
    it "returns correct contribution analysis" do
      html = @c_card.format.render_header
      expect(html).to have_tag("i",:with=>{:class=>"fa fa-quote-left"})

    end
  end
  
end