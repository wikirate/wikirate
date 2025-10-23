RSpec.describe Card::Set::Type::Company::Export do
  let(:company) { Card["Samsung"] }

  context "with JSON Format" do
    describe "atom view" do
      subject { render_view :atom, { name: company.name }, format: :json }

      specify do
        is_expected.to include(name: "Samsung",
                               id: company.id,
                               url: "http://wikirate.org/Samsung.json",
                               type: "Company",
                               "alias" => nil,
                               "headquarters" => nil,
                               "open_corporates_id" => nil,
                               "sec_cik" => nil,
                               "os_id" => nil,
                               "wikipedia" => "Samsung")
      end
    end

    describe "molecule view" do
      subject { render_view :molecule, { name: company.name }, format: :json }

      specify do
        is_expected
          .to include(
            name: "Samsung",
            id: company.id,
            url: "http://wikirate.org/Samsung.json",
            type: a_hash_including(name: "Company"),
            "wikipedia" => a_hash_including(name: "Samsung+Wikipedia"),
            "open_corporates_id" => nil,
            "alias" => nil,
            "headquarters" => nil,
            answers_url: "http://wikirate.org/Samsung+Answer.json"
          )
      end
    end
  end

  describe "view: :molecule, format: :jsonld" do
    subject { render_view :molecule, { name: company.name }, format: :jsonld }

    specify do
      is_expected
        .to include(
          "@type" => "Company",
          "@id" => a_kind_of(String),
          "@context" => "/context/Company.jsonld"
        )
    end
  end

  context "with CSV Format" do
    subject { render_view :row, { name: company.name }, format: :csv }

    specify do
      is_expected.to include(company.name, company.id)
    end
  end
end
