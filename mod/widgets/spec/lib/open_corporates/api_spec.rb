RSpec.describe OpenCorporates::API do
  specify "#fetch_industry_codes" do
    list = described_class.fetch_industry_codes
    expect(list).to eq []
  end
end