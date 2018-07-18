# -*- encoding : utf-8 -*-

require_relative "../../../support/cached_count_shared_examples"

RSpec.describe Card::Set::TypePlusRight::WikirateTopic::Project do
  it_behaves_like "cached count", ["Force", :project], 1 do
    let :add_one do
      Card.fetch("Empty Project", :wikirate_topic, new: {}).add_item! "Force"
    end
    let :delete_one do
      Card["Evil Project", :wikirate_topic].drop_item! "Force"
    end
  end
end
