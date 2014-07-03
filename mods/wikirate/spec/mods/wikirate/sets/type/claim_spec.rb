# -*- encoding : utf-8 -*-

describe Card::Set::Type::Claim do
	it "should handle too long claim" do
		login_as 'joe_user'	
		card = Card.new(   :type=>"Claim", :name=>"2"*101 )
		card.should_not be_valid
		card.errors.should have_key :claim
		card.errors[:claim]=="The claim is too long(length >100)"

    end
	it "should handle normal claim" do
		login_as 'joe_user'	
		card = Card.new(   :type=>"Claim", :name=>"2"*100 )
		card.should be_valid
    end
end
