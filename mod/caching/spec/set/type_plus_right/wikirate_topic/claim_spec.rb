# encoding: UTF-8

require_relative "../../../support/cached_count_shared_examples"

RSpec.describe Card::Set::TypePlusRight::WikirateTopic::Claim do
  it_behaves_like "cached count", ["Force", :claim], 1 do
    let :add_one do
      Card.fetch(sample_note(2), :wikirate_topic, new: {}).add_item! "Force"
    end
    let :delete_one do
      Card[sample_note, :wikirate_topic].drop_item! "Force"
    end
  end
end
