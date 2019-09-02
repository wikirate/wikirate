# -*- encoding : utf-8 -*-

require_relative "../../../support/cached_count_shared_examples"

RSpec.describe Card::Set::TypePlusRight::WikirateCompany::MetricAnswer do
  it_behaves_like "cached count", "Death Star+answer", 31, 2 do
    # increment = 2, because one researched answer + one calculated answer
    let :add_one do
      Card["Jedi+disturbances in the force"].create_values true do
        Death_Star "1999" => "yes"
      end
    end
    let :delete_one do
      Card["Jedi+disturbances in the force+Death Star+1990"].delete
    end
  end
end
