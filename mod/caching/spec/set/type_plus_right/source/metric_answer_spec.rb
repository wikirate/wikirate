require_relative "../../../support/cached_count_shared_examples"

RSpec.describe Card::Set::TypePlusRight::Source::MetricAnswer do
  it_behaves_like "cached count", "#{Card::Name[:star_wars_source]}+answer", 19, 1 do
    let :add_one do
      Card["Jedi+Weapons"].create_values do
        Samsung "1977" => { value: "hand", source: Card[:star_wars_source] }
      end
    end
    let :delete_one do
      Card["Jedi+cost of planets destroyed+Death Star+1977"].delete
    end
  end
end
