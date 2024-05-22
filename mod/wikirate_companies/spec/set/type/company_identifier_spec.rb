RSpec.describe Card::Set::Type::CompanyIdentifier do
  it "caches excerpts" do
    expect(described_class.excerpts).to eq(["Open Corporates ID", "OAR ID", "Wikipedia"])
  end
end
