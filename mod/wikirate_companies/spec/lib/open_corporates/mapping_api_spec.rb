require_relative "../../../lib/open_corporates/mapping_api"

RSpec.describe OpenCorporates::MappingApi do
  it "new company with wikipedia entry" do
    allow(described_class)
      .to receive(:json_response) do
        { company_number: "C0806592",
          incorporation_jurisdiction_code: "code1",
          jurisdiction_code: "code2" }.to_json
      end
    expect(described_class.fetch_oc_company_number({}).company_number).to eq "C0806592"
  end

  xit "new company with headquarters entry" do
    company = create "Wilmar International",
                     type: :company,
                     fields: { headquarters: :oc_sg.cardname }
    expect(company.open_corporates).to eq "199904785Z"
  end
end
