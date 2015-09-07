# -*- encoding : utf-8 -*-

describe Card::Set::Type::Pointer::Pointer do
  before do
    login_as 'joe_user'
    Card::Env::params["export"] = "true"
  end
  describe "rendering json in export mode" do
    context "pointer card" do
      it "should contain cards in the pointer card and its children" do
        small_blind = Card.create! :name => "Elbert Hubbard", :type_id => Card::BasicID, :content => "Do not take life too seriously."
        small_blind_1 = Card.create! :name => "Elbert Hubbard+hello world", :type_id => Card::BasicID, :content => "You will never get out of it alive."
        pointer_card = Card.create! :name=>"normal pointer",:type_id=>Card::PointerID, :content =>"[[#{small_blind.name}]]\r\n[[#{small_blind_1.name}]]"

        big_blind = Card.create! :name => "special means special", :type_id => Card::PointerID, :content=>"[[#{pointer_card.name}]]"
        array = big_blind.format(:json).render_core

        expect(array).to include(:name=>"normal pointer",:type=>"Pointer",:content=>"[[Elbert Hubbard]]\n[[Elbert Hubbard+hello world]]")
        expect(array).to include(:name=>"Elbert Hubbard",:type=>"Basic",:content=>"Do not take life too seriously.")
        expect(array).to include(:name=>"Elbert Hubbard+hello world",:type=>"Basic",:content=>"You will never get out of it alive.")
      end
      it "stops while the depth count > 10" do
        pointer_card = Card.create! :name=>"normal pointer",:type_id=>Card::PointerID, :content =>"[[normal pointer]]"
        big_blind = Card.create! :name => "special means special", :type_id => Card::PointerID, :content=>"[[#{pointer_card.name}]]"
        array = big_blind.format(:json).render_core

        expect(array).to include(:name=>"normal pointer",:type=>"Pointer",:content=>"[[normal pointer]]")
 
      end
    end
    context "search card" do
      it "should contain cards from search card and its children" do
        small_blind = Card.create! :name => "Elbert Hubbard", :type_id => Card::BasicID, :content => "Do not take life too seriously."
        small_blind_1 = Card.create! :name => "Elbert Hubbard+hello world", :type_id => Card::BasicID, :content => "You will never get out of it alive."
        small_blind_2 = Card.create! :name => "Elbert Hubbard+quote", :type_id => Card::BasicID, :content => "Procrastination is the art of keeping up with yesterday."
        search_card = Card.create! :name=>"search card",:type_id=>Card::SearchTypeID, :content =>%{{"left":"Elbert Hubbard"}}

        big_blind = Card.create! :name => "special means special", :type_id => Card::PointerID, :content=>"[[#{search_card.name}]]"
        array = big_blind.format(:json).render_core
        
        expect(array).to include(:name=>"search card",:type=>"Search",:content=>%{{"left":"Elbert Hubbard"}})
        expect(array).to include(:name=>"Elbert Hubbard+hello world",:type=>"Basic",:content=>"You will never get out of it alive.")
        expect(array).to include(:name=>"Elbert Hubbard+quote",:type=>"Basic",:content=>"Procrastination is the art of keeping up with yesterday.")
      end
    end
  end
end

