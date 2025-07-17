# encoding: UTF-8

RSpec.describe Card::Set::TypePlusRight::Topic::Source do
  it_behaves_like "cached count", "Wikirate ESG Topics+Environment+source", 3, 1 do
    let :add_one do
      Card.fetch(sample_source(:apple), :topic, new: {}).add_item! %i[esg_topics environment].cardname
    end
    let :delete_one do
      Card.fetch(sample_source(:space_opera), :topic).drop_item! %i[esg_topics environment].cardname
    end
  end
end
