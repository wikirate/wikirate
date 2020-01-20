# -*- encoding : utf-8 -*-

require_relative "../../../support/cached_count_shared_examples"

RSpec.describe Card::Set::TypePlusRight::Metric::MetricAnswer do
  it_behaves_like "cached count", "Jedi+disturbances in the force+answer", 11, 1 do
    let :add_one do
      Card["Jedi+disturbances in the force"].create_answers true do
        Samsung "1977" => "yes"
      end
    end
    let :delete_one do
      Card["Jedi+disturbances in the force+Death Star+1990"].delete
    end
  end
end
