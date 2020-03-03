# -*- encoding : utf-8 -*-

require_relative "../../../lib/open_corporates/api"

RSpec.describe Card::Set::Right::OpenCorporates do
  let(:api_response) do
    path =
      File.expand_path("../../../support/open_corporates_api_response.json", __FILE__)
    JSON.parse(File.read(path))["results"]["company"]
  end

  def stub_oc_api changes={}
    oc_api = class_double("OpenCorporates::Api")
    allow(oc_api).to receive(:fetch_companies).and_return(api_response.merge(changes))
    stub_const("OpenCorporates::Api", oc_api)
  end

  describe "view: oc_search_link" do
    it "shows external link" do
      view = render_view :oc_search_link, name: "Los Pollos Hermanos+open corporates"
      expect(view).to have_tag(:a, with: { class: "external-link" })
    end
  end

  describe "view :core" do
    subject { render_view :core_async_content, name: "Google LLC+open corporates" }

    def have_table rows
      have_tag :table do
        rows.each do |cells|
          with_tag :tr do
            cells.each do |text|
              with_tag :td, text: text
            end
          end
        end
      end
    end

    it "shows all fields" do
      stub_oc_api
      is_expected.to have_table [
        ["Name", "BP P.L.C."],
        ["Previous Names", "BP AMOCO P.L.C., THE BRITISH PETROLEUM COMPANY P.L.C."],
        ["Jurisdiction", "California (United States)"],
        ["Registered Address", "1 ST JAMES'S SQUARE, LONDON, SW1Y 4PD"],
        ["Incorporation date", /14 April 1909 \((almost|over|about) \d+ years ago\)/],
        ["Company Type", "Public Limited Company"],
        %w[Status Active]
      ]
    end

    it "hides empty fields" do
      stub_oc_api "current_status" => ""
      is_expected.not_to include("Status")
      is_expected.to have_table([["Name", "BP P.L.C."]])
    end

    context "api not available" do
      it "shows error message" do
        stub_const("OpenCorporates::Api::HOST", "open-corporates-is-down.org")
        is_expected.to have_tag "div.alert", text: /service temporarily not available/
      end
    end
  end
end
