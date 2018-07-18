shared_examples "badge count" do |total, bronze, silver, gold|
  it "returns correct total count" do
    expect(badge_count).to eq total
  end

  it "returns correct bronze count" do
    expect(badge_count(:bronze)).to eq bronze
  end

  it "returns correct silver count" do
    expect(badge_count(:silver)).to eq silver
  end

  it "returns correct gold count" do
    expect(badge_count(:gold)).to eq gold
  end
end
