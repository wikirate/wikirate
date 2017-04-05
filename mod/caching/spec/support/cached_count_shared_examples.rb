shared_examples "cached count" do |name, count|
  let(:card) { Card.fetch name }
  it "has correct count" do
    expect(card.count).to eq count
  end

  it "has correct cached count" do
    expect(card.cached_count).to eq count
  end

  it "increases count" do
    add_one
    expect(card.count).to eq count + 1
    expect(card.cached_count).to eq count + 1
  end

  it "decreases count" do
    delete_one
    expect(card.count).to eq count - 1
    expect(card.cached_count).to eq count - 1
  end
end
