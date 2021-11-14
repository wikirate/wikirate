# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::TypePlusRight::WikirateTopic::Dataset do
  it_behaves_like "cached count", ["Force", :dataset], 1, 1 do
    let :add_one do
      Card.fetch("Empty Dataset", :wikirate_topic, new: {}).add_item! "Force"
    end
    let :delete_one do
      Card["Evil Dataset", :wikirate_topic].drop_item! "Force"
    end
  end
end
