# encoding: UTF-8

require_relative "../../../support/cached_count_shared_examples"

RSpec.describe Card::Set::TypePlusRight::WikirateCompany::Claim do
  it_behaves_like "cached count", ["Death Star", :claim], 1 do
    let :add_one do
      Card.fetch(sample_note(2), :wikirate_company, new: {}).add_item! "Death Star"
    end
    let :delete_one do
      Card[sample_note, :wikirate_company].drop_item! "Death Star"
    end
  end
end
