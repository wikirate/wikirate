require_relative "../../../support/cached_count_shared_examples"

RSpec.describe Card::Set::TypePlusRight::Source::Metric do
  it_behaves_like "cached count", "#{sample_source("Apple").name}+metric", 2 do
    let :add_one do
      Card["Jedi+disturbances in the force"].create_values do
        Samsung "1977" => { value: "yes", source: sample_source("Apple") }
      end
    end
    let :delete_one do
      Card["Jedi+disturbances in the force+Death Star+1990"].delete
    end
  end
end
