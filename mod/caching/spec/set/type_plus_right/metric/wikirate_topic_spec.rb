# -*- encoding : utf-8 -*-

require_relative "../../../support/cached_count_shared_examples"

RSpec.describe Card::Set::TypePlusRight::Metric::WikirateTopic do
  it_behaves_like "cached count", "Jedi+disturbances in the force+topics", 1 do
    let :add_one do
      Card["Jedi+disturbances in the force+topics"].add_item! "Animal Welfare"
    end
    let :delete_one do
      Card["Jedi+disturbances in the force+topics"].drop_item! "Force"
    end
  end
end
