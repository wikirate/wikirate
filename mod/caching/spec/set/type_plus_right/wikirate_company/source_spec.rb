# encoding: UTF-8

require_relative "../../../support/cached_count_shared_examples"

RSpec.describe Card::Set::TypePlusRight::WikirateCompany::Source do
  it_behaves_like "cached count", ["Death Star", :source], 4, 1 do
    let :add_one do
      card = Card.fetch sample_source(:apple), :wikirate_company, new: {}
      card.add_item! "Death Star"
    end

    let :delete_one do
      Card[sample_source(:star_wars), :wikirate_company].drop_item! "Death Star"
    end
  end
end
