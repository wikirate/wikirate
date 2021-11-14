# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::TypePlusRight::WikirateTopic::WikirateCompany do
  it_behaves_like "cached count", ["Taming", :wikirate_company], 4, 1 do
    let :add_one do
      Card.fetch("Joe User+RM+topics", new: {}).add_item! "Taming"
    end
    let :delete_one do
      Card["Joe User+researched number 3+topics"].drop_item! "Taming"
    end
  end

  it_behaves_like "cached count", ["Force", :wikirate_company], 4, 1 do
    let :add_one do
      Card["Jedi+disturbances in the Force"].create_answers true do
        Samsung "1977" => "no"
      end
    end
    let :delete_one do
      Card["Jedi+disturbances in the Force+SPECTRE+2000"].delete
    end
  end
end
