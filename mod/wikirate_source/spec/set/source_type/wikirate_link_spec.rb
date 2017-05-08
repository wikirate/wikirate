# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::SourceType::WikirateLink do
  PDF_URL = "http://www.adobe.com/content/dam/Adobe/en/devnet/acrobat/pdfs/"\
            "pdf_open_parameters.pdf".freeze
  HTML_URL = "http://www.loremipsum.net".freeze
  it "imports pdf link" do
    page = create_page url: PDF_URL, no_upload: false
    file = page.fetch(trait: :file).file
    expect(file).to be_truthy
    expect(file.size).to eq 131_821
  end

  it "imports html link as pdf" do
    page = create_page url: HTML_URL, no_upload: false
    file = page.fetch(trait: :file).file
    expect(file).to be_truthy
    expect(file.size).to be > 100
  end
end
