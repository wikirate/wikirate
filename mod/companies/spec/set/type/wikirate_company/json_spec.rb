RSpec.describe Card::Set::Type::WikirateCompany::Json do
  let(:company) { Card["Samsung"] }

  describe "atom view" do
    subject { render_view :atom, { name: company.name }, format: :json }

    specify do
      is_expected.to include(name: "Samsung",
                             id: company.id,
                             url: "http://wikirate.org/Samsung.json",
                             type: "Company",
                             wikipedia: nil,
                             open_corporates: nil,
                             oar_id: nil,
                             alias: [],
                             headquarters: nil)
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
          wikipedia: a_hash_including(id: nil),
          open_corporates: a_hash_including(id: nil),
          alias: a_hash_including(id: nil),
          headquarters: a_hash_including(id: nil),
          answers_url: "http://wikirate.org/Samsung+Answer.json"
        )
    end
  end
end
