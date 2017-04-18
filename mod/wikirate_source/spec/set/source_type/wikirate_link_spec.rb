# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::SourceType::WikirateLink do
  PDF_URL = "http://www.adobe.com/content/dam/Adobe/en/devnet/acrobat/pdfs/"\
            "pdf_open_parameters.pdf"
  HTML_URL = "http://www.loremipsum.net"
  it "imports pdf link" do
    page = create_link_source PDF_URL
    file = page.fetch(trait: :file).file
    expect(file).to be_truthy
    expect(file.size).to eq 131821
  end

  it "imports html link as pdf" do
    page = create_link_source HTML_URL
    file = page.fetch(trait: :file).file
    expect(file).to be_truthy
    expect(file.size).to be > 100
  end
end