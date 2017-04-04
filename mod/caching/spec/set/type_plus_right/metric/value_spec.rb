# -*- encoding : utf-8 -*-

require_relative "../../../support/cached_count_shared_examples"

RSpec.describe Card::Set::TypePlusRight::Metric::Value do
  it_behaves_like "cached count", 11 do
    let(:card) { Card["Jedi+disturbances in the force+value"] }
    let :add_one do
      Card["Jedi+disturbances in the force"].create_values true do
        Samsung "1977" => "yes"
      end
    end
  end
end
