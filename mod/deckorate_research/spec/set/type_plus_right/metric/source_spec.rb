RSpec.describe Card::Set::TypePlusRight::Metric::Source do
  it_behaves_like "cached count", "Jedi+disturbances in the force+source", 2, 1 do
    let :add_one do
      apple_source = sample_source :apple
      create_records "Jedi+disturbances in the force" do
        Samsung "1977" => { value: "yes", source: apple_source }
      end
    end
    let :delete_one do
      # this deletes multiple records that use the same source,
      # which in this case is necessary to get the source to decrement.
      Card["Jedi+disturbances in the force+Death Star"].delete
    end
  end
end
