# -*- encoding : utf-8 -*-



describe Card::Set::Right::OpenCorporates do
  let(:api_response) do
    path =
      File.expand_path("../../../support/open_corporates_api_response.json", __FILE__)
    JSON.parse File.read(path)
  end

  let(:table_view) { render_view :table, name: "Google Inc+open corporates" }

  def have_row label, value
    have_tag :table do
      with_tag :tr do
        with_tag :td, text: label
        with_tag :td, text: value
      end
    end
  end

  def stub_oc_api
    oc_api = class_double("OpenCorporates::API")
    allow(oc_api).to receive(:fetch).and_return(api_response)
    stub_const("OpenCorporates::API", oc_api)
  end

  subject do
    stub_oc_api
    table_view
  end

  specify "view :table" do
    is_expected.to have_row("Name", "BP P.L.C.")
    is_expected.to have_row("Status", "Active")
    is_expected.to have_row("Registered Address", "1 ST JAMES'S SQUARE, LONDON, SW1Y 4PD)")
    is_expected.to have_row "Company Type", "Public Limited Company"
    is_expected.to have_row("Jurisdiction", "1 ST JAMES'S SQUARE, LONDON, SW1Y 4PD)")
  end

end
