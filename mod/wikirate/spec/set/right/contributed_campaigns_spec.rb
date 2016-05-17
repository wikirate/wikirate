# describe Card::Set::Right::ContributedCampaigns do

#   before do
#     @user_card = Card["joe_user"]
#     campaigns = Card.search :type=>"Campaign", :limit=>5

#     campaign = campaigns[0]
#     vision = Card[campaign.name+"+vision"] || Card.new(:name=>campaign.name+"+vision")
#     vision.content = "One of my most productive days was throwing away 1000 lines of code."
#     vision.save!

#     campaign1 = campaigns[1]
#     vision1 = Card[campaign1.name+"+vision"] || Card.new(:name=>campaign1.name+"+vision")
#     vision1.content = "When in doubt, use brute force."
#     vision1.save!
#     @c_card = @user_card.fetch(:trait=>:contributed_campaigns)
#   end
#   describe ".contribution_counts" do
#     it "returns correct contribution count" do
#       expect(@c_card.contribution_count).to eq(2)
#     end
#   end
#   describe "header view" do
#     it "returns correct contribution analysis" do
#       html = @c_card.format.render_header
#       expect(html).to have_tag("i",:with=>{:class=>"fa fa-bullhorn"})

#     end
#   end

# end
