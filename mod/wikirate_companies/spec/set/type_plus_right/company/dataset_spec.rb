# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::TypePlusRight::Company::Dataset do
  it_behaves_like "cached count", ["Death Star", :dataset], 1, 1 do
    let :add_one do
      Card.fetch("Empty Dataset", :company, new: {}).add_item! "Death Star"
    end
    let :delete_one do
      Card["Evil Dataset", :company].drop_item! "Death Star"
    end
  end
end
