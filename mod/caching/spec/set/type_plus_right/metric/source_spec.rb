require_relative "../../../support/cached_count_shared_examples"

RSpec.describe Card::Set::TypePlusRight::Metric::Source do
  it_behaves_like "cached count", "Jedi+disturbances in the force+source", 2, 1 do
    let :add_one do
      Card["Jedi+disturbances in the force"].create_values do
        Samsung "1977" => { value: "yes", source: sample_source(:apple) }
      end
    end
    let :delete_one do
      # this deletes multiple answers that use the same source,
      # which in this case is necessary to get the source to decrement.
      Card["Jedi+disturbances in the force+Death Star"].delete
    end
  end
end
