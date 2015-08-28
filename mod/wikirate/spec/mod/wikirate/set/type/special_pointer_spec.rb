require 'json'
describe Card::Set::Type::SpecialPointer do
  before do
    login_as 'joe_user' 
  end
  describe "render in json format core view" do
    context "advance mode" do
      context "simple card" do
        it "should contain a simple card in array" do
          small_blind = Card.create! :name => "Elbert Hubbard", :type_id => Card::BasicID, :content => "Do not take life too seriously. You will never get out of it alive."
          big_blind = Card.create! :name => "special means special", :type_id => Card::SpecialPointerID, :content=>"[[#{small_blind.name}]]"
          array = big_blind.format(:json).render_core
          expect(array[0]).to include(:name=>"Elbert Hubbard",:type=>"Basic",:content=>"Do not take life too seriously. You will never get out of it alive.")
        end

      end
      context "pointer card" do
        it "should contain cards in the pointer card and its children" do
          small_blind = Card.create! :name => "Elbert Hubbard", :type_id => Card::BasicID, :content => "Do not take life too seriously."
          small_blind_1 = Card.create! :name => "Elbert Hubbard+hello world", :type_id => Card::BasicID, :content => "You will never get out of it alive."
          pointer_card = Card.create! :name=>"normal pointer",:type_id=>Card::PointerID, :content =>"[[#{small_blind.name}]]"

          big_blind = Card.create! :name => "special means special", :type_id => Card::SpecialPointerID, :content=>"[[#{pointer_card.name}]]"
          array = big_blind.format(:json).render_core
          expect(array).to include(:name=>"normal pointer",:type=>"Pointer",:content=>"[[Elbert Hubbard]]")
          expect(array).to include(:name=>"Elbert Hubbard",:type=>"Basic",:content=>"Do not take life too seriously.")
          expect(array).to include(:name=>"Elbert Hubbard+hello world",:type=>"Basic",:content=>"You will never get out of it alive.")
        end
      end
      context "special pointer card" do
        it "should contain cards in the special pointer card card and its children" do
          small_blind = Card.create! :name => "Elbert Hubbard", :type_id => Card::BasicID, :content => "Do not take life too seriously."
          small_blind_1 = Card.create! :name => "Elbert Hubbard+hello world", :type_id => Card::BasicID, :content => "You will never get out of it alive."
          pointer_card = Card.create! :name=>"normal pointer",:type_id=>Card::PointerID, :content =>"[[#{small_blind.name}]]"

          big_blind = Card.create! :name => "special means special", :type_id => Card::SpecialPointerID, :content=>"[[#{pointer_card.name}]]"

          dealer = Card.create! :name => "special means special means special", :type_id => Card::SpecialPointerID, :content=>"[[special means special]]"

          array = dealer.format(:json).render_core
          expect(array).to include(:name=>"special means special",:type=>"special_pointer",:content=>"[[normal pointer]]")
          expect(array).to include(:name=>"normal pointer",:type=>"Pointer",:content=>"[[Elbert Hubbard]]")
          expect(array).to include(:name=>"Elbert Hubbard",:type=>"Basic",:content=>"Do not take life too seriously.")
          expect(array).to include(:name=>"Elbert Hubbard+hello world",:type=>"Basic",:content=>"You will never get out of it alive.")
        end
      end
      context "search card" do
        it "should contain cards from search card and its children" do
          small_blind = Card.create! :name => "Elbert Hubbard", :type_id => Card::BasicID, :content => "Do not take life too seriously."
          small_blind_1 = Card.create! :name => "Elbert Hubbard+hello world", :type_id => Card::BasicID, :content => "You will never get out of it alive."
          small_blind_2 = Card.create! :name => "Elbert Hubbard+quote", :type_id => Card::BasicID, :content => "Procrastination is the art of keeping up with yesterday."
          search_card = Card.create! :name=>"search card",:type_id=>Card::SearchTypeID, :content =>%{{"left":"Elbert Hubbard"}}

          big_blind = Card.create! :name => "special means special", :type_id => Card::SpecialPointerID, :content=>"[[#{search_card.name}]]"
          array = big_blind.format(:json).render_core
          
          expect(array).to include(:name=>"search card",:type=>"Search",:content=>%{{"left":"Elbert Hubbard"}})
          expect(array).to include(:name=>"Elbert Hubbard+hello world",:type=>"Basic",:content=>"You will never get out of it alive.")
          expect(array).to include(:name=>"Elbert Hubbard+quote",:type=>"Basic",:content=>"Procrastination is the art of keeping up with yesterday.")
        end
      end
    end
    context "lite mode" do
      context "search card" do
        it "should contain cards from search card " do
          Card::Env::params["lite"] = "true"
          small_blind = Card.create! :name => "Elbert Hubbard", :type_id => Card::BasicID, :content => "Do not take life too seriously."
          small_blind_1 = Card.create! :name => "Elbert Hubbard+hello world", :type_id => Card::BasicID, :content => "You will never get out of it alive."
          small_blind_2 = Card.create! :name => "Elbert Hubbard+quote", :type_id => Card::BasicID, :content => "Procrastination is the art of keeping up with yesterday."
          search_card = Card.create! :name=>"search card",:type_id=>Card::SearchTypeID, :content =>%{{"left":"Elbert Hubbard"}}

          big_blind = Card.create! :name => "special means special", :type_id => Card::SpecialPointerID, :content=>"[[#{search_card.name}]]"
          array = big_blind.format(:json).render_core
          
          expect(array).to include(:name=>"search card",:type=>"Search",:content=>%{{"left":"Elbert Hubbard"}})
          expect(array).to include(:name=>"Elbert Hubbard+hello world",:type=>"Basic",:content=>"You will never get out of it alive.")
          expect(array).to include(:name=>"Elbert Hubbard+quote",:type=>"Basic",:content=>"Procrastination is the art of keeping up with yesterday.")
        end
      end
    end
  end
end