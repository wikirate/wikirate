# -*- encoding : utf-8 -*-

require_relative "../../../support/cached_count_shared_examples"

RSpec.describe Card::Set::TypePlusRight::WikirateCompany::Project do
  it_behaves_like "cached count", 1 do
    let :card do
      Card["Death Star+projects"]
    end
    let :add_one do
      Card["Empty Project", :wikirate_company].add_item! "Death Star"
    end
  end
end
