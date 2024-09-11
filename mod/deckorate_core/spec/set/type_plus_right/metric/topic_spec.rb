# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::TypePlusRight::Metric::Topic do
  it_behaves_like "cached count", "Jedi+disturbances in the force+topics", 1, 1 do
    let :add_one do
      Card["Jedi+disturbances in the force+topics"].add_item! "Animal Welfare"
    end
    let :delete_one do
      Card["Jedi+disturbances in the force+topics"].drop_item! "Force"
    end
  end
end
