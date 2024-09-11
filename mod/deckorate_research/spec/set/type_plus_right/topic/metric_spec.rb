# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::TypePlusRight::Topic::Metric do
  it_behaves_like "cached count", "Force+metric", 1, 1 do
    let :add_one do
      Card.fetch(["Joe User+researched number 2", :topic], new: {})
          .add_item! "Force"
    end
    let :delete_one do
      Card["Jedi+disturbances in the Force", :topic].drop_item! "Force"
    end
  end
end
