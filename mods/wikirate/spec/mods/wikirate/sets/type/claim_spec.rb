# -*- encoding : utf-8 -*-

describe Card::Set::Type::Claim do
	it "should handle too long claim" do
		login_as 'joe_user'
		_cardname = "2" * 101
    	card = Card.create! :name => _cardname, :type=>"Claim"
    	puts "@@ #{card.errors[:abort]}"
    end
  
end
