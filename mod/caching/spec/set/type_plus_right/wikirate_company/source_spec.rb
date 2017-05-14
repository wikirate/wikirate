# encoding: UTF-8

require_relative "../../../support/cached_count_shared_examples"

RSpec.describe Card::Set::TypePlusRight::WikirateCompany::Source do
  it_behaves_like "cached count", ["Death Star", :source], 3 do
    let :add_one do
      Card.fetch(sample_source("Apple"), :wikirate_company, new: {}).add_item! "Death Star"
    end
    let :delete_one do
      Card[sample_source, :wikirate_company].drop_item! "Death Star"
    end
  end
end
