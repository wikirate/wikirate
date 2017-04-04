# -*- encoding : utf-8 -*-

require_relative "../../../support/cached_count_shared_examples"

RSpec.describe Card::Set::TypePlusRight::WikirateCompany::WikirateTopic do
  it_behaves_like "cached count", 1 do
    let :card do
      Card["Death Star+topics"]
    end
    let :add_one do
      Card["Jedi+disturbances in the force+topics"].add_item! "Animal Welfare"
    end
  end

  it_behaves_like "cached count", 1 do
    let :card do
      Card["SPECTRE+topics"]
    end
    let :add_one do
      Card["Fred+dinosaurlabor"].create_values true do
        SPECTRE "1977" => "no"
      end
    end
  end
end
