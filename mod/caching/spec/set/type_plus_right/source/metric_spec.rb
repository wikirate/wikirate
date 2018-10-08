require_relative "../../../support/cached_count_shared_examples"

RSpec.describe Card::Set::TypePlusRight::Source::Metric do
  it_behaves_like "cached count", "#{Card::Name[:star_wars_source]}+metric", 10 do
    let :add_one do
      Card["Jedi+disturbances in the force"].create_values do
        Samsung "1977" => { value: "yes", source: Card[:star_wars_source] }
      end
    end
    let :delete_one do
      Card["Jedi+disturbances in the force+Death Star+1977"].delete
    end
  end
end
