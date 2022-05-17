# -*- encoding : utf-8 -*-

require "link_thumbnailer"

RSpec.describe Card::Set::Self::Source do
  let(:page_card) { Card["Source"] }
  let(:json_format) { page_card.format(format: :json) }

  describe "browse sources page" do
    subject do
      render_card :titled_content, name: :source
    end

    it "has 'add source' button" do
      is_expected.to have_tag "a.btn", text: "Add Source",
                                       with: { href: "/new/Source" }
    end

    it "has list of sources" do
      is_expected.to have_tag "div.search-result-list" do
        with_tag "div.search-result-item" do
          with_text /thereaderwiki\.com/
          with_text /Star Wars/
        end
        with_tag "div.search-result-item" do
          with_text /thereaderwiki\.com/
          with_text /Space Opera/
        end
      end
    end

    it "has sources ordered by 'most recent'" do
      is_expected.to have_tag "div.search-result-list" do
        with_text(/Opera.+Space Opera.+Star Wars/m)
      end
    end

    describe "filter bars" do
      it "has Title filter open by default" do
        expect(page_card.format.render_filter_bars)
          .to have_tag("div.accordion-collapse.show") do
            with_tag"input[name='filter[wikirate_title]']"
          end
      end
    end
  end

  describe "#iframable?" do
    subject { json_format.iframable? pdf_url, user_agent }

    let(:pdf_url) do
      "https://brendanzagaeski.appspot.com/minimal.pdf"
      # "https://cdn.mozilla.net/pdfjs/helloworld.pdf"
    end

    context "when user agent is Firefox" do
      let(:user_agent) { "Firefox" }

      it "returns true" do
        is_expected.to be_truthy
      end
    end

    context "when user agent is not Firefox" do
      let(:user_agent) { "Chrome" }

      it "returns false" do
        is_expected.to be_falsey
      end
    end
  end

  describe "'result' value of json view check_iframable" do
    subject do
      Card::Env.params[:url] = url
      json_format._render!(:check_iframable)[:result]
    end

    context "with iframable website" do
      let(:url) { "http://example.org" }

      it { is_expected.to be true }
      # this website need special handle, but it seems the page is down now
      # url = "http://www.peri.umass.edu/toxicair_current/"
      # Card::Env.params[:url] = url
      # result = json_format._render!(:check_iframable)
      # expect(result[:result]).to be true
    end

    context "with non-iframable website" do
      let(:url) { "http://www.google.com" }

      it { is_expected.to be false }
    end

    context "with nonsense website" do
      let(:url) { "helloworld" }

      it { is_expected.to be false }
    end

    context "with empty website" do
      let(:url) { nil }

      it { is_expected.to be false }
    end
  end

  describe "view :metadata" do
    let(:result_hash) do
      Card::Env.params[:url] = url
      JSON.parse json_format._render!(:metadata)
    end

    context "with invalid url" do
      let(:url) { "abcdefg" }

      it "has empty title" do
        expect(result_hash["title"]).to eq("")
      end
      it "has empty description" do
        expect(result_hash["description"]).to eq("")
      end
      it "has error 'invalid url'" do
        expect(result_hash["error"]).to eq("invalid url")
      end
    end

    context "with empty url" do
      let(:url) { nil }

      it "has empty title" do
        expect(result_hash["title"]).to eq("")
      end
      it "has empty description" do
        expect(result_hash["description"]).to eq("")
      end
      it "has error 'empty url'" do
        expect(result_hash["error"]).to eq("empty url")
      end
    end

    context "with existing url" do
      let(:source_card) { sample_source }
      let(:source_title) { Card.fetch("#{source_card.name}+title").content }
      let(:source_desc) do
        Card.fetch("#{source_card.name}+description").content
      end
      let(:url) do
        source_card.fetch(:wikirate_link).content
      end

      it "has correct title" do
        expect(result_hash["title"]).to eq source_title
      end

      it "has correct description" do
        expect(result_hash["description"]).to eq source_desc
      end

      it "has no errors" do
        expect(result_hash["error"]).to be_empty
      end
    end
    context "with non-existing url" do
      let(:url) { "http://www.heise.de" }
      let(:preview) { LinkThumbnailer.generate(url) }

      it "has correct title" do
        expect(result_hash["title"]).to eq(preview.title)
      end

      it "has correct description" do
        expect(result_hash["description"]).to eq(preview.description)
      end

      it "has no errors" do
        expect(result_hash["error"]).to be_empty
      end
    end
  end

  describe "view :unknown" do
    subject { render_card :unknown, name: source_card.name }

    let(:source_card) { sample_source }

    it "shows the link" do
      is_expected.to eq render_card(:link, name: source_card.name)
    end
  end
end
