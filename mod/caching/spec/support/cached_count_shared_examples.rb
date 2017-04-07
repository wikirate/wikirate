shared_examples "check count" do |count|
  it "has correct count" do
    expect(card.count).to eq count
  end
  it "has correct cached count" do
    expect(card.cached_count).to eq count
  end
end

shared_examples "cached count" do |name, count|
  let(:card) { Card.fetch name }

  include_examples "check count", count

  context "when item added" do
    before do
      Card::Auth.as_bot { add_one }
    end
    include_examples "check count", count + 1
  end

  context "when item deleted" do
    before do
      Card::Auth.as_bot { delete_one }
    end
    include_examples "check count", count - 1
  end
end
