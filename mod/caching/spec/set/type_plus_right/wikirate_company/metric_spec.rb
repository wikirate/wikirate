# -*- encoding : utf-8 -*-

require_relative "../../../support/cached_count_shared_examples"

RSpec.describe Card::Set::TypePlusRight::WikirateCompany::Metric do
  it_behaves_like "cached count", 12 do
    let :card do
      Card["Death Star+metrics"]
    end
    let :add_one do
      Card["Joe User+researched number 2"].create_values true do
        Death_Star "1977" => 5
      end
    end
  end
end
