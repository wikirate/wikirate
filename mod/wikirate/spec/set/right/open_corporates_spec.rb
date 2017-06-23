# -*- encoding : utf-8 -*-

require_relative "../../../lib/open_corporates/api"

describe Card::Set::Right::OpenCorporates do
  let(:api_response) do
    path =
      File.expand_path("../../../support/open_corporates_api_response.json", __FILE__)
    JSON.parse File.read(path)
  end

  def stub_oc_api changes={}
    oc_api = class_double("OpenCorporates::API")
    api_response["results"]["company"].merge! changes if changes.present?
    allow(oc_api).to receive(:fetch).and_return(api_response)
    stub_const("OpenCorporates::API", oc_api)
  end

  describe "view :core" do
    subject { render_view :core_async_content, name: "Google Inc+open corporates" }

    def have_row label, value
      have_tag :table do
        with_tag :tr do
          with_tag :td, text: label
          with_tag :td, text: value
        end
      end
    end

    it "shows all fields" do
      stub_oc_api
      is_expected.to have_row "Name", "BP P.L.C."
      is_expected.to have_row "Previous Names", "BP AMOCO P.L.C., THE BRITISH PETROLEUM COMPANY P.L.C."
      is_expected.to have_row "Jurisdiction", "California (United States)"
      is_expected.to have_row "Registered Address", "1 ST JAMES'S SQUARE, LONDON, SW1Y 4PD"
      is_expected.to have_row "Incorporation date", /14 April 1909 \(about \d+ years ago\)/
      is_expected.to have_row "Company Type", "Public Limited Company"
      is_expected.to have_row "Status", "Active"
    end

    it "hides empty fields" do
      stub_oc_api "current_status" => ""
      is_expected.not_to include("Status")
      is_expected.to have_row("Name", "BP P.L.C.")
    end

    context "api not available" do
      it "shows error message" do
        stub_const("OpenCorporates::API::HOST", "open-corporates-is-down.org")
        is_expected.to have_tag "div.alert", text: /service temporarily not available/
      end
    end
  end
end
