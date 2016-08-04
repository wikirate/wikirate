# -*- encoding : utf-8 -*-
require "link_thumbnailer"

describe Card::Set::Self::Source do
  before do
    @page_card = Card["Source"]
  end
  describe "while check iframable" do
    it "should return true for a iframable website" do
      url = "http://example.org"

      Card::Env.params[:url] = url
      result = @page_card.format(format: :json)._render(:check_iframable)
      expect(result[:result]).to be true
      # this website need special handle, but it seems the page is down now
      # url = "http://www.peri.umass.edu/toxicair_current/"
      # Card::Env.params[:url] = url
      # result = @page_card.format(format: :json)._render(:check_iframable)
      # expect(result[:result]).to be true
    end

    it "should return false for non iframble website" do
      url = "http://www.google.com"

      Card::Env.params[:url] = url
      result = @page_card.format(format: :json)._render(:check_iframable)
      expect(result[:result]).to be false
    end
    context "when rendering pdf in firefox" do
      it "returns true if it is firefox" do
        url = "http://www.adobe.com/content/dam/Adobe/en/devnet/acrobat/pdfs/pdf_open_parameters.pdf"
        result = @page_card.format(format: :json).iframable? url, "Firefox"
        expect(result).to be(true)
      end
      it "returns false if it is not firefox" do
        url = "http://www.adobe.com/content/dam/Adobe/en/devnet/acrobat/pdfs/pdf_open_parameters.pdf"
        result = @page_card.format(format: :json).iframable? url, "Chrome"
        expect(result).to be(false)
      end
    end

    it "should return false for non sense website" do
      url = "helloworld"

      Card::Env.params[:url] = url
      result = @page_card.format(format: :json)._render(:check_iframable)
      expect(result[:result]).to be false
    end
    it "should return false for empty website" do
      result = @page_card.format(format: :json)._render(:check_iframable)
      expect(result[:result]).to be false
    end
  end
  describe "get meta data of url" do
    it "handles invalid url" do
      url = "abcdefg"

      Card::Env.params[:url] = url
      result = @page_card.format(format: :json)._render(:metadata)

      result_hash = JSON.parse(result)
      expect(result_hash["title"]).to eq("")
      expect(result_hash["description"]).to eq("")
      expect(result_hash["error"]).to eq("invalid url")
    end
    it "handles empty url" do
      url = ""

      Card::Env.params[:url] = url
      result = @page_card.format(format: :json)._render(:metadata)

      result_hash = JSON.parse(result)
      expect(result_hash["title"]).to eq("")
      expect(result_hash["description"]).to eq("")
      expect(result_hash["error"]).to eq("empty url")
    end
    it "handles normal existing url " do
      url = "http://www.google.com/?q=wikirateissocoolandawesomeyouknow"
      sourcepage = create_page_with_sourcebox url, {}, "true"

      Card::Env.params[:url] = url
      result = @page_card.format(format: :json)._render(:metadata)

      result_hash = JSON.parse(result)
      source_page_content = Card.fetch("#{sourcepage.name}+title").content
      expect(source_page_content).to eq result_hash["title"]
      source_page_desc = Card.fetch("#{sourcepage.name}+description").content
      expect(source_page_desc).to eq result_hash["description"]
      expect(result_hash["error"].empty?).to be true
    end
    it "handles normal non existing url " do
      url = "http://www.google.com/?q=wikirateissocoolandawesomeyouknow"

      Card::Env.params[:url] = url
      result = @page_card.format(format: :json)._render(:metadata)

      result_hash = JSON.parse(result)
      preview = LinkThumbnailer.generate(url)

      expect(result_hash["title"]).to eq(preview.title)
      expect(result_hash["description"]).to eq(preview.description)
      expect(result_hash["error"].empty?).to be true
    end
    it 'shows the link for view "missing"' do
      sourcepage = create_page_with_sourcebox nil, {}, "true"
      html = render_card :missing, name: sourcepage.name
      expect(html).to eq(render_card(:link, name: sourcepage.name))
    end
  end
end
