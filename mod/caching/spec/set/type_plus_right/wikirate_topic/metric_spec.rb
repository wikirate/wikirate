# -*- encoding : utf-8 -*-

require_relative "../../../support/cached_count_shared_examples"

RSpec.describe Card::Set::TypePlusRight::WikirateTopic::Metric do
  it_behaves_like "cached count", "Force+metric", 1 do
    let :add_one do
      Card.fetch(["Joe User+researched number 2", :wikirate_topic], new: {})
          .add_item! "Force"
    end
    let :delete_one do
      Card["Jedi+disturbances in the Force", :wikirate_topic].drop_item! "Force"
    end
  end
end
