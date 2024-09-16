shared_examples "check count" do |count|
  it "has correct count" do
    expect(card.count).to eq count
  end
  it "has correct cached count" do
    Card::Count.refresh_flagged
    expect(card.cached_count).to eq count
  end
end

shared_examples "cached count" do |name, count, increment|
  let(:card) { Card.fetch name }

  include_examples "check count", count

  context "when item added" do
    before { Card::Auth.as_bot { add_one } }
    include_examples "check count", count + increment
  end

  context "when item deleted" do
    before do
      Card::Auth.as_bot { delete_one }
    end
    include_examples "check count", count - increment
  end
end
