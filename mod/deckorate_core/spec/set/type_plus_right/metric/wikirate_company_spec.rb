# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::TypePlusRight::Metric::WikirateCompany do
  it_behaves_like "cached count", "Jedi+disturbances in the force+companies", 4, 1 do
    let :add_one do
      Card["Jedi+disturbances in the force"].create_answers true do
        Samsung "1977" => "yes"
      end
    end
    let :delete_one do
      Card["Jedi+disturbances in the Force+SPECTRE+2000"].delete
    end
  end
end
