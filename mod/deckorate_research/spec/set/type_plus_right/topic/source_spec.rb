# encoding: UTF-8

RSpec.describe Card::Set::TypePlusRight::Topic::Source do
  it_behaves_like "cached count", "Force+source", 3, 1 do
    let :add_one do
      Card.fetch(sample_source(:apple), :topic, new: {}).add_item! "Force"
    end
    let :delete_one do
      Card.fetch(sample_source(:space_opera), :topic).drop_item! "Force"
    end
  end
end
