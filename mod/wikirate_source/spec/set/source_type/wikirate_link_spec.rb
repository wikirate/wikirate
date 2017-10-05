# -*- encoding : utf-8 -*-

# require_relative '../../../../../vendor/wagn/card/spec/support/matchers'

RSpec.describe Card::Set::SourceType::WikirateLink do
  PDF_URL = "http://www.adobe.com/content/dam/Adobe/en/devnet/acrobat/pdfs/"\
            "pdf_open_parameters.pdf".freeze
  HTML_URL = "http://www.loremipsum.net".freeze

  it "imports pdf link" do
    page = create_page url: PDF_URL, import: true
    expect(page).to have_file_trait.of_size(131_821)
  end

  it "imports html link as pdf" do
    skip "needs to be turned via config options of for all other tests;"\
         "turned of for all tests now"
    page = create_page url: HTML_URL, import: true
    expect(page).to have_file_trait.of_size(be > 100)
  end

  context "import flag set to false" do
    it "doesn't import link" do
      page = create_page url: HTML_URL, import: false
      expect(page.import?).to be_falsey
      expect(page).not_to have_file_trait
    end
  end
end
