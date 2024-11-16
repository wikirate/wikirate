RSpec.describe Card::Set::TypePlusRight::Record::Discussion do
  it "updates lookup" do
    record_card = sample_record
    record_card.discussion_card.update! content: "nice weather, eh?"
    expect(record_card.record.comments).to match(/weather/)
  end
end
