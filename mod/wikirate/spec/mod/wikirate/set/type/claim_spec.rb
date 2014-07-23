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
    #create the testing webpage first
    url = 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
    Card::Env.params[:sourcebox] = 'true'
    sourcepage = Card.create! :type_id=>Card::WebpageID,:subcards=>{ '+Link' => {:content=> url} }
    preview = LinkThumbnailer.generate(url)
    Card::Env.params[:sourcebox] = 'false'

    card = Card.new(   :type=>"Claim", :name=>"2"*100 ,:subcards=>{ '+source' => {:content=> url,:type_id=>Card::WebpageID}})
    card.should be_valid
  end

  it "should require +source card " do
    #nth here
    card = Card.new(   :type=>"Claim", :name=>"2"*100)
    card.should_not be_valid
    card.errors.should have_key :link
    card.errors[:link]=="is empty"
    #without type
    card = Card.new(   :type=>"Claim", :name=>"2"*100,:subcards=>{ '+source' => {:content=> 'http://www.google.com/?q=a1'}})
    card.should_not be_valid
    card.errors.should have_key :link
    card.errors[:link]=="is pointing to invalid page"

    #with a non exisiting url in any webpage
    url = 'http://www.google.com/?q=wikirateissocoolandawesomeyouknowandidontthinkthiscardexists'
    card = Card.new(   :type=>"Claim", :name=>"2"*100 ,:subcards=>{ '+source' => {:content=> url,:type_id=>Card::WebpageID}})
    card.should_not be_valid
    card.errors.should have_key :link
    card.errors[:link]=="is pointing to a non exisiting page"
  end

end

