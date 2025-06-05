# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::TypePlusRight::Source::WikirateLink do
  PDF_URL = "https://brendanzagaeski.appspot.com/minimal.pdf".freeze
  HTML_URL =
    "https://www.cs.unc.edu/~jbs/resources/www/page_prep/intro-html/dummy.html".freeze

  it "imports pdf link" do
    page = create_source PDF_URL
    expect(page).to have_file_trait.of_size(739)
  end

  it "imports html link as pdf" do
    page = create_source HTML_URL
    expect(page).to have_file_trait.of_size(be > 100)
  end
end
