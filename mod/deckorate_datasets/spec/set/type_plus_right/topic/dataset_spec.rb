# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::TypePlusRight::Topic::Dataset do
  it_behaves_like "cached count", [%i[esg_topics environment].cardname, :dataset], 1, 1 do
    let :add_one do
      Card.fetch("Empty Dataset", :topic, new: {}).add_item! %i[esg_topics environment].cardname
    end
    let :delete_one do
      Card["Evil Dataset", :topic].drop_item! %i[esg_topics environment].cardname
    end
  end
end
