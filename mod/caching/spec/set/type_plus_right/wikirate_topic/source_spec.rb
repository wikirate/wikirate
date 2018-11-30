# encoding: UTF-8

require_relative "../../../support/cached_count_shared_examples"

RSpec.describe Card::Set::TypePlusRight::WikirateTopic::Source do
  it_behaves_like "cached count", "Force+source", 3, 1 do
    let :add_one do
      Card.fetch(sample_source(:apple), :wikirate_topic, new: {}).add_item! "Force"
    end
    let :delete_one do
      Card.fetch(sample_source(:space_opera), :wikirate_topic).drop_item! "Force"
    end
  end
end
