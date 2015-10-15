# -*- encoding : utf-8 -*-
require 'link_thumbnailer'

describe Card::Set::Type::Source do

  describe "rendering preview view" do
    before do
      @url = "http://existingpage.com"
      @company = "Amazon.com, Inc."
      @topic = "Natural Resource Use"
      @existing_source = create_page_with_sourcebox @url,{"+Company"=>@company,"+Topic"=>@topic},'false'
      
    end

    context "text source" do
      before do
        @text_source = Card.create! :type_id=>Card::SourceID,:subcards=>{'+Text'=>{ :content=>"There are 2 hard problems in computer science: cache invalidation, naming things, and off-by-1 errors.",:type_id=>Card::BasicID}}
        @result = @text_source.format._render_preview
      end
      it "shows correction options" do

        expect(@result).to have_tag("ul", :with=>{:class=>"navbar-right"}) do
          with_tag "a",  :with=>{"data-target"=>"#tab_details"}
          with_tag "a",  :with=>{"data-target"=>"#tab_claims", :href=>"/#{@text_source.cardname.url_key}+source_note_list?slot[hide]=header,menu"}
          with_tag "a",  :with=>{"data-target"=>"#tab_metrics", :href=>"/#{@text_source.cardname.url_key}+metric_search?slot[hide]=header,menu"}
        end
      end
      it "shows text source" do
        expect(@result).to have_tag("div", :with=>{:id=>"text_source",:class=>"webpage-preview"}) do
          with_tag "div",  :with=>{:id=>"#{@text_source.cardname.url_key}+Text"}
        end

      end
    end
    context "file source" do
      before do
        pdf_file = File.open("#{Rails.root}/mod/wikirate_source/spec/set/type/source/test_pdf.pdf")
        @pdf_source = Card.create! :type_id=>Card::SourceID,:subcards=>{'+File'=>{ :file=>pdf_file,:type_id=>Card::FileID}}
        
        @result = @pdf_source.format._render_preview
      end
      it "shows correction options" do

        expect(@result).to have_tag("ul", :with=>{:class=>"navbar-right"}) do
          with_tag "a",  :with=>{"data-target"=>"#tab_details"}
          with_tag "a",  :with=>{"data-target"=>"#tab_claims", :href=>"/#{@pdf_source.cardname.url_key}+source_note_list?slot[hide]=header,menu"}
          with_tag "a",  :with=>{"data-target"=>"#tab_metrics", :href=>"/#{@pdf_source.cardname.url_key}+metric_search?slot[hide]=header,menu"}
        end
      end
      context "pdf file" do
        it "shows pdf" do
          file_card = @pdf_source.fetch :trait=>:file
          expect(@result).to have_tag("div", :with=>{:id=>"pdf-preview"}) do
            with_tag "iframe", with: {
              id: "source-preview-iframe", 
              src: "files/viewer.html?file=#{file_card.attachment.url}"
            } 
          end
        end
      end
      context "image file" do
        it "uses img tag" do
          img_file = File.open("#{Rails.root}/mod/wikirate_source/spec/set/type/source/test_logo.png")
          image_source = Card.create! :type_id=>Card::SourceID,:subcards=>{'+File'=>{ :file=>img_file,:type_id=>Card::FileID}}
          result = image_source.format._render_preview
          file_card = image_source.fetch :trait=>:file
          expect(result).to have_tag("div", :with=>{:id=>"pdf-preview"}) do
            with_tag "img", :with=>{:id=>"source-preview-iframe", :src=>file_card.attachment.url}
          end
        end
      end
      context "others format" do
        it "render redirect notice" do
          word_file = File.open("#{Rails.root}/mod/wikirate_source/spec/set/type/source/test_word.docx")
          word_source = Card.create! :type_id=>Card::SourceID,:subcards=>{'+File'=>{ :file=>word_file,:type_id=>Card::FileID}}
          result = word_source.format._render_preview
          expect(result).to have_tag("div", :with=>{:id=>"source-preview-iframe",:class=>"webpage-preview non-previewable"}) do
            with_tag "div", :with=>{:class=>"redirect-notice"}
          end
        end
      end

    end
    context "link source" do
      before do
        @url = "http://newsource.com"
        @company = "Amazon.com, Inc."
        @topic = "Natural Resource Use"
        @existing_source = create_page_with_sourcebox @url,{"+Company"=>@company,"+Topic"=>@topic},'false'
        @result = @existing_source.format._render_preview
      end
      it "shows correction options" do
        expect(@result).to have_tag("ul", :with=>{:class=>"navbar-right"}) do
          with_tag "a",  :with=>{"data-target"=>"#tab_details"}
          with_tag "a",  :with=>{"data-target"=>"#tab_claims", :href=>"/#{@existing_source.cardname.url_key}+source_note_list?slot[hide]=header,menu"}
          with_tag "a",  :with=>{"data-target"=>"#tab_metrics", :href=>"/#{@existing_source.cardname.url_key}+metric_search?slot[hide]=header,menu"}
          with_tag "a",  :with=>{:href=>@existing_source.fetch(:trait=>:wikirate_link).content}
        end
      end
      it "shows iframe" do
        expect(@result).to have_tag("div", :with=>{:id=>"webpage-preview"}) do
          with_tag "iframe", :with=>{:id=>"source-preview-iframe", :src=>@url}
        end
      end
    end


  end


end
