# -*- encoding : utf-8 -*-

describe Card::Set::Right::WikirateTag do
  before do
    login_as 'joe_user' 
  end
  it "should create tag card(s) while creating +tag card(s)" do
    url = 'http://www.google.com/?q=newpage'
    Card::Env.params[:sourcebox] = 'true'
    sourcepage = Card.create! :type_id=>Card::WebpageID,:subcards=>{ '+Link' => {:content=> url} }
    card = Card.create! :type=>"Claim", :name=>"Testing Claim",:subcards=>{ "+tag"=>{:content=>"[[zzz]]\n[[xxx]]", :type=>"pointer"},'+source' => {:content=> url,:type_id=>Card::WebpageID}}
    Card.exists?("zzz").should == true
    Card.exists?("xxx").should == true
   #Card["zzz"]&&Card["xxx"]
  end

end
