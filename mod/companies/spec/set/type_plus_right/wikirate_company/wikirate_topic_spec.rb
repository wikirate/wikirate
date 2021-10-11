# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::TypePlusRight::WikirateCompany::WikirateTopic do
  it_behaves_like "cached count", "Death Star+topics", 2, 1 do
    let :add_one do
      Card["Jedi+disturbances in the force+topics"].add_item! "Animal Welfare"
    end
    let :delete_one do
      Card["Jedi+disturbances in the force+topics"].drop_item! "Force"
    end
  end

  it_behaves_like "cached count", "SPECTRE+topics", 1, 1 do
    let :add_one do
      Card["Fred+dinosaurlabor"].create_answers true do
        SPECTRE "1977" => "no"
      end
    end
    let :delete_one do
      Card["Jedi+disturbances in the Force+SPECTRE+2000"].delete
    end
  end
end
