# -*- encoding : utf-8 -*-

require_relative "../../../support/cached_count_shared_examples"

RSpec.describe Card::Set::TypePlusRight::WikirateCompany::Project do
  it_behaves_like "cached count", ["Death Star", :project], 1, 1 do
    let :add_one do
      Card.fetch("Empty Project", :wikirate_company, new: {}).add_item! "Death Star"
    end
    let :delete_one do
      Card["Evil Project", :wikirate_company].drop_item! "Death Star"
    end
  end
end
