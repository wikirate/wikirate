RSpec.describe Card::Set::Self::WikirateCompany::Factories do
  describe "#search_factories" do
    subject { JSON.parse Card[:wikirate_company].format(:json).render_search_factories }

    let(:google_fields) do
      {
        "name" => "Google LLC",
        "id" => "Google LLC".card_id,
        "url_key" => "Google_LLC"
      }
    end

    let(:california_id) do
      "California (United States)".card_id
    end

    example "empty params" do
      is_expected.to eq []
    end

    example "search by country" do
      Card::Env.params[:country_code] = california_id
      is_expected.to contain_exactly google_fields
    end

    example "search by name" do
      Card::Env.params[:keyword] = "Hermano"
      is_expected.to contain_exactly a_hash_including("name" => "Los Pollos Hermanos")
    end

    example "search by name and country" do
      Card::Env.params[:keyword] = "oog"
      Card::Env.params[:country_code] = california_id
      is_expected.to contain_exactly google_fields
    end

    example "search by address and country" do
      Card::Env.params[:keyword] = "Mountain"
      Card::Env.params[:country_code] = california_id
      is_expected.to contain_exactly google_fields
    end

    example "search with no result" do
      Card::Env.params[:keyword] = "empty result"
      Card::Env.params[:country_code] = california_id
      is_expected.to eq []
    end
  end
end
