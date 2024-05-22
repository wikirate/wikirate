RSpec.describe Card::Set::Type::CompanyIdentifier do
  it "caches excerpts" do
    expect(described_class.excerpts).to eq(["OpenCorporates ID", "OS ID", "Wikipedia"])
  end
end
