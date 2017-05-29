# encoding: UTF-8

require_relative "../../../support/cached_count_shared_examples"

RSpec.describe Card::Set::TypePlusRight::WikirateTopic::Source do
  it_behaves_like "cached count", "Force+source", 2 do
    let :add_one do
      Card.fetch(sample_source("Apple"), :wikirate_topic, new: {}).add_item! "Force"
    end
    let :delete_one do
      Card.fetch(sample_source("Space_opera"), :wikirate_topic).drop_item! "Force"
    end
  end
end
