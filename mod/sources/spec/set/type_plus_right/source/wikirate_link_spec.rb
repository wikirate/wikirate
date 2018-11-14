# -*- encoding : utf-8 -*-

# require_relative '../../../../../vendor/wagn/card/spec/support/matchers'

RSpec.describe Card::Set::TypePlusRight::Source::WikirateLink do
  PDF_URL = "https://brendanzagaeski.appspot.com/minimal.pdf".freeze
  HTML_URL = "https://www.lipsum.com".freeze
  before do
    Cardio.config.x.import_sources = true
  end

  after do
    Cardio.config.x.import_sources = false
  end

  it "imports pdf link" do
    page = create_source PDF_URL
    expect(page).to have_file_trait.of_size(739)
  end

  it "imports html link as pdf" do
    page = create_source HTML_URL
    expect(page).to have_file_trait.of_size(be > 100)
  end

  # context "import flag set to false" do
  #   it "doesn't import link" do
  #     page = create_source HTML_URL, import: false
  #     expect(page).not_to be_import
  #     expect(page).not_to have_file_trait
  #   end
  # end
end
