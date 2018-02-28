RSpec.describe Card::Set::Self::WikirateCompany::Factories do
  describe "#search_factories" do
    subject { Card[:wikirate_company].format(:json).render_search_factories }

    example "empty params" do
      is_expected.to eq "[]"
    end

    example "search by country" do
      Card::Env.params[:country_code] = "oc_us_ca"
      is_expected.to eq '["Google Inc."]'
    end

    example "search by name" do
      Card::Env.params[:keyword] = "Hermano"
      is_expected.to eq '["Los Pollos Hermanos"]'
    end

    example "search by name and country" do
      Card::Env.params[:keyword] = "oog"
      Card::Env.params[:country_code] = "oc_us_ca"
      is_expected.to eq '["Google Inc."]'
    end

    example "search by address and country" do
      Card::Env.params[:keyword] = "Mountain"
      Card::Env.params[:country_code] = "oc_us_ca"
      is_expected.to eq '["Google Inc."]'
    end

    example "search with no result" do
      Card::Env.params[:keyword] = "empty result"
      Card::Env.params[:country_code] = "oc_us_ca"
      is_expected.to eq "[]"
    end
  end
end
