# -*- encoding : utf-8 -*-

require "link_thumbnailer"

describe Card::Set::Type::Source, "source preview" do
  describe "rendering preview view" do
    before do
      @url = "http://existingpage.com"
      @company = "Amazon.com, Inc."
      @topic = "Natural Resource Use"
      @existing_source =
        create_page url: @url, box: false,
                    subcards: { "+Company" => @company,
                                "+Topic" => @topic }
    end

    context "text source" do
      before do
        text = "There are 2 hard problems in computer science: cache "\
               "invalidation, naming things, and off-by-1 errors."
        @text_source = create_source text: text
        @result = @text_source.format._render_preview
      end

      it "shows correction options" do
        expect(@result).to have_tag("ul", with: { class: "nav-tabs" }) do
          with_tag "a",  with: { "data-url" => "/#{@text_source.name.url_key}?view=details_tab" }
          with_tag "a",  with: { "data-url" => "/#{@text_source.name.url_key}?view=metric_tab" }
        end
      end

      it "shows text source" do
        expect(@result).to have_tag("div", with: { id: "text_source", class: "webpage-preview" }) do
          with_tag "div",  with: { id: "#{@text_source.name.url_key}+Text" }
        end
      end
    end

    context "file source" do
      before do
        pdf_file = File.open("#{Rails.root}/mod/wikirate_source/spec/set/type/source/test_pdf.pdf")
        @pdf_source = create_source file: pdf_file
        @result = @pdf_source.format._render_preview
      end
      it "shows correction options" do
        expect(@result).to have_tag("ul", with: { class: "nav-tabs" }) do
          with_tag "a",  with: { "data-url" => "/#{@pdf_source.name.url_key}?view=details_tab" }
          with_tag "a",  with: { "data-url" => "/#{@pdf_source.name.url_key}?view=metric_tab" }
        end
      end
      context "pdf file" do
        it "shows pdf" do
          file_card = @pdf_source.fetch trait: :file
          expect(@result).to have_tag("div", with: { id: "pdf-preview" }) do
            with_tag "iframe", with: {
              id: "source-preview-iframe",
              src: "/pdfjs/web/viewer.html?file=#{file_card.attachment.url}"
            }
          end
        end
      end
      context "image file" do
        it "uses img tag" do
          img_file = File.open("#{Rails.root}/mod/wikirate_source/spec/set/type/source/test_logo.png")
          image_source = create_source file: img_file
          result = image_source.format._render_preview
          file_card = image_source.fetch trait: :file
          expect(result).to have_tag("div", with: { id: "pdf-preview" }) do
            with_tag "img", with: { id: "source-preview-iframe", src: file_card.attachment.url }
          end
        end
      end
      context "others format" do
        it "render redirect notice" do
          word_file = File.open("#{Rails.root}/mod/wikirate_source/spec/set/type/source/test_word.docx")
          word_source = create_source file: word_file
          result = word_source.format._render_preview
          expect(result).to have_tag("div", with: { id: "source-preview-iframe", class: "webpage-preview non-previewable" }) do
            with_tag "div", with: { class: "redirect-notice" }
          end
        end
      end
    end
    context "link source" do
      before do
        @url = "http://wagn.org"
        @company = "Amazon.com, Inc."
        @topic = "Natural Resource Use"
        @existing_source = create_page url: @url, box: false,
                                       subcards: { "+Company" => @company,
                                                   "+Topic" => @topic }
        @result = @existing_source.format._render_preview
      end
      it "shows correction options" do
        expect(@result).to have_tag("ul", with: { class: "nav-tabs" }) do
          with_tag "a",  with: { "data-url" => "/#{@existing_source.name.url_key}?view=details_tab" }
          with_tag "a",  with: { "data-url" => "/#{@existing_source.name.url_key}?view=metric_tab" }
          with_tag "a",  with: { href: @existing_source.fetch(trait: :wikirate_link).content }
        end
      end
      it "shows iframe" do
        expect(@result).to have_tag("div", with: { id: "webpage-preview" }) do
          with_tag "iframe", with: { id: "source-preview-iframe", src: @url }
        end
      end
    end
  end
end
