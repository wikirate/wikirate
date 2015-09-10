describe Card::Set::Right::ContributedSources do

  before do
    
    source_list = Array.new
    Card::Auth.current_id = Card::WagnBotID
    Card::Auth.as_bot do
      (0...5).each do |i|
        source_list.push(create_page("https://www.google.co.uk/?q=hello#{i}"))
      end
    end

    login_as "joe_user" 
    source_list.each  do |source|
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