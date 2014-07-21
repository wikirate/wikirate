# -*- encoding : utf-8 -*-

describe Card::Set::Type::Claim do
  before do
    login_as 'joe_user' 
  end
  it "should handle too long claim" do
    card = Card.new(   :type=>"Claim", :name=>"2"*101 )
    card.should_not be_valid
    card.errors.should have_key :claim
    card.errors[:claim]=="The claim is too long(length >100)"
  end
  
  it "should handle normal claim" do
    
    card = Card.new(   :type=>"Claim", :name=>"2"*100 ,:subcards=>{ '+source' => {:content=> 'http://www.google.com/?q=a1'}})
    card.should be_valid
  end

  it "should handle empty source claim" do
    card = Card.new(   :type=>"Claim", :name=>"2"*100)
    card.should_not be_valid
    card.errors.should have_key :link
    card.errors[:link]=="is empty"
  end

end
