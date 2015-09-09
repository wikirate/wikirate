describe Card::Set::Right::ContributedClaims do

  before do

    # claims = Card.search :type_id=>Card::ClaimID, :limit=>3
    claim_list = Array.new
    Card::Auth.current_id = Card::WagnBotID
    Card::Auth.as_bot do
      (0...3).each do |i|
        source = create_page "https://www.google.co.uk/?q=hello#{i}"
        claim = Card.create! :type_id=>Card::ClaimID, :name=>"claim #{i}" ,:subcards=>{ '+source' => {:content=>"[[#{source.name}]]",:type_id=>Card::PointerID}}
        claim_list.push claim

      end
    end

    login_as "joe_user" 
    claim_list.each  do |claim|
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