RSpec.describe Card::Set::Type::CompanyIdentifier do
  it "caches excerpts" do
    expect(described_class.excerpts).to eq(["OAR ID", "Open Corporates ID", "Wikipedia"])
  end
end
