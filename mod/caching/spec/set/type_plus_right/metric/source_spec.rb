require_relative "../../../support/cached_count_shared_examples"

RSpec.describe Card::Set::TypePlusRight::Metric::Source do
  it_behaves_like "cached count", 1 do
    let :card do
      Card["Jedi+disturbances in the force+source"]
    end
    let :add_one do
      Card["Jedi+disturbances in the force"].create_values do
        Samsung "1977" => { value: "yes", source: sample_source(2) }
      end
    end
  end
end
