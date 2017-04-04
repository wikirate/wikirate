shared_examples "cached count" do |count|
  it "has correct count" do
    expect(card.count).to eq count
  end

  it "has correct cached count" do
    expect(card.cached_count).to eq count
  end

  it "updates count" do
    add_one
    expect(card.count).to eq count + 1
    expect(card.cached_count).to eq count + 1
  end
end
