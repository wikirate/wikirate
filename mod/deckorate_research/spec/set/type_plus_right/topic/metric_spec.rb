# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::TypePlusRight::Topic::Metric do
  it_behaves_like "cached count", "Taming+metric", 2, 1 do
    let :add_one do
      Card.fetch(["Joe_User+small_single", :topic], new: {}).add_item! "Taming"
    end
    let :delete_one do
      Card["Joe User+researched number 3", :topic].drop_item! "Taming"
    end
  end
end
