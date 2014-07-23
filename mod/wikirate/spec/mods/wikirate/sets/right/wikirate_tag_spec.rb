# -*- encoding : utf-8 -*-

describe Card::Set::Right::WikirateTag do
  before do
    login_as 'joe_user' 
  end
  it "should create tag card(s) while creating +tag card(s)" do
    
    card = Card.create! :type=>"Claim", :name=>"Testing Claim" ,:subcards=>{ "+tag"=>{:content=>"[[zzz]]\n[[xxx]]", :type_id=>"47"}}
    Card.exists?("zzz").should == true
    Card.exists?("xxx").should == true
   #Card["zzz"]&&Card["xxx"]
  end

end
