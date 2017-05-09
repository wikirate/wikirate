# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::SourceType::WikirateLink do
  PDF_URL = "http://www.adobe.com/content/dam/Adobe/en/devnet/acrobat/pdfs/"\
            "pdf_open_parameters.pdf".freeze
  HTML_URL = "http://www.loremipsum.net".freeze

  def file page
    page.fetch(trait: :file).file
  end

  it "imports pdf link" do
    page = create_page url: PDF_URL, import: true
    expect(file(page)).to be_truthy
    expect(file.size).to eq 131_821
  end

  it "imports html link as pdf" do
    page = create_page url: HTML_URL, import: true
    expect(file(page)).to be_truthy
    expect(file.size).to be > 100
  end

  context "import flag set to false" do
    it "doesn't import link" do
      page = create_page url: HTML_URL, import: false
      expect(page.import?).to be_falsey
      expect(page.fetch(trait: :file)).to eq nil
    end
  end
end
