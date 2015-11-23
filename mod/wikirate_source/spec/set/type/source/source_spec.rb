# -*- encoding : utf-8 -*-
require 'link_thumbnailer'

describe Card::Set::Type::Source do
  describe "while creating a Source" do
    before do
      login_as 'joe_user' 
    end
    it "should add title,description" do
      
      url = 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
      Card::Env.params[:sourcebox] = 'true'
      sourcepage = Card.create! :type_id=>Card::SourceID,:subcards=>{ '+Link' => {:content=> url}, '+File' =>{:type_id=>Card::FileID}, '+Text'=>{:type_id=>Card::BasicID,:content=>""} }
      preview = LinkThumbnailer.generate(url)

      expect(Card.fetch("#{ sourcepage.name }+title").content).to eq(preview.title)
      expect(Card.fetch("#{ sourcepage.name }+description").content).to eq(preview.description)
     
    end
    it "should handle empty source" do
        url = ''
        Card::Env.params[:sourcebox] = 'true'
        sourcepage = Card.new :type_id=>Card::SourceID,:subcards=>{ '+Link' => {:content=> url}, '+File' =>{:type_id=>Card::FileID}, '+Text'=>{:type_id=>Card::BasicID,:content=>""} }
        expect(sourcepage).not_to be_valid
        expect(sourcepage.errors).to have_key :source
        
        expect(sourcepage.errors[:source]).to include("Please at least add one type of source")
    end

    it 'creates website card with actions' do
      url = 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
      Card::Env.params[:sourcebox] = 'true'
      sourcepage = Card.create! type_id: Card::SourceID, subcards: {
        '+Link' => { content: url },
        '+File' => { type_id: Card::FileID },
        '+Text' => { type_id: Card::BasicID, content: '' }
      }
      website_card = sourcepage.fetch trait: :wikirate_website
      expect(website_card.last_action).to be
    end

    describe "while creating duplicated source on claim page" do
      it "should return exisiting url" do
        url = 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
        Card::Env.params[:sourcebox] = 'true'
        firstsourcepage = Card.create :type_id=>Card::SourceID,:subcards=>{ '+Link' => {:content=> url} , '+File' =>{:type_id=>Card::FileID}, '+Text'=>{:type_id=>Card::BasicID,:content=>""}}
        secondsourcepage = Card.create :type_id=>Card::SourceID,:subcards=>{ '+Link' => {:content=> url}, '+File' =>{:type_id=>Card::FileID}, '+Text'=>{:type_id=>Card::BasicID,:content=>""} }
        expect(firstsourcepage.name).to eq(secondsourcepage.name)
      end
    end
    describe "while creating duplicated source on source page" do
      it "should show error" do
        url = 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
        
        firstsourcepage = Card.create :type_id=>Card::SourceID,:subcards=>{ '+Link' => {:content=> url}, '+File' =>{:type_id=>Card::FileID}, '+Text'=>{:type_id=>Card::BasicID,:content=>""} }
        secondsourcepage = Card.new :type_id=>Card::SourceID,:subcards=>{ '+Link' => {:content=> url}, '+File' =>{:type_id=>Card::FileID}, '+Text'=>{:type_id=>Card::BasicID,:content=>""} }
        
        expect(secondsourcepage).not_to be_valid
        expect(secondsourcepage.errors).to have_key :link
        expect(secondsourcepage.errors[:link]).to include("exists already. <a href='/#{firstsourcepage.name}'>Visit the source.</a>")

      end
    end
    context "while creating without anything" do
      it do 
        sourcepage = Card.new :type_id=>Card::SourceID
        expect(sourcepage).not_to be_valid
        expect(sourcepage.errors).to have_key :source
        expect(sourcepage.errors[:source]).to include("Please at least add one type of source")
      end
    end
    context "while creating with more than one source type " do
      it do 
        url = 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
        
        sourcepage = Card.new :type_id=>Card::SourceID,:subcards=>{ '+Link' => {:content=> url},'+File' =>{:type_id=>Card::FileID}, '+Text' => {:content=>"Hello boys!",:type_id=>Card::BasicID} }
        expect(sourcepage).not_to be_valid
        expect(sourcepage.errors).to have_key :source
        expect(sourcepage.errors[:source]).to include("Please only add one type of source")
      end
    end
    describe "while creating a source with a file link" do 
      context "link points to a file" do
        it "downloads it and saves as a file source" do
          pdf_url = "http://www.relacweb.org/conferencia/images/documentos/Hoteles_cerca.pdf"
          sourcepage = Card.create :type_id=>Card::SourceID,:subcards=>{ '+Link' => {:content=> pdf_url}, '+File' =>{:type_id=>Card::FileID}, '+Text'=>{:type_id=>Card::BasicID,:content=>""}}
          expect(sourcepage.errors).to be_empty
          source_file = sourcepage.fetch(:trait=>:file)
          expect(source_file).to_not be_nil
          expect(sourcepage.fetch(:trait=>:wikirate_link)).to be_nil
          expect(Card.exists?("#{sourcepage.name}+title")).to eq(false)
          expect(Card.exists?("#{sourcepage.name}+description")).to eq(false)
          expect(File.exist?source_file.file.path).to be true

        end
        it "handles this special url and saves as a file source" do
          pdf_url = "https://www.unglobalcompact.org/system/attachments/9862/original/Sinopec_2010_Sustainable_Development_Report.pdf?1302508855"
          sourcepage = Card.create :type_id=>Card::SourceID,:subcards=>{ '+Link' => {:content=> pdf_url}, '+File' =>{:type_id=>Card::FileID}, '+Text'=>{:type_id=>Card::BasicID,:content=>""}}
          expect(sourcepage.errors).to be_empty
          expect(sourcepage.fetch(:trait=>:file)).to_not be_nil
          expect(sourcepage.fetch(:trait=>:wikirate_link)).to be_nil
        end
        it "won't create file source if the file is bigger than '*upload max'" do
          pdf_url = "http://cartographicperspectives.org/index.php/journal/article/download/cp49-issue/489"
          sourcepage = Card.create :type_id=>Card::SourceID,:subcards=>{ '+Link' => {:content=> pdf_url}, '+File' =>{:type_id=>Card::FileID}, '+Text'=>{:type_id=>Card::BasicID,:content=>""}}
          expect(sourcepage.errors).to be_empty
          expect(sourcepage.fetch(:trait=>:wikirate_link)).to_not be_nil
          expect(sourcepage.fetch(:trait=>:file)).to be_nil
        end
      end
    end
    describe "while creating a source with a wikirate link" do 
      context "a source link" do
        it "return the source card" do
          
          Card::Env.params[:sourcebox] = 'true'
          url = 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
          sourcepage = Card.create :type_id=>Card::SourceID,:subcards=>{ '+Link' => {:content=> url}, '+File' =>{:type_id=>Card::FileID}, '+Text'=>{:type_id=>Card::BasicID,:content=>""} }
          url_key = sourcepage.cardname.url_key
          new_source_url = "#{ Card::Env[:protocol] }#{ Card::Env[:host] }/#{url_key }"
          new_sourcepage = Card.create :type_id=>Card::SourceID,:subcards=>{ '+Link' => {:content=> new_source_url} }
          expect(sourcepage.name).to eq(new_sourcepage.name)

        end
      end
      context "a non source link" do
        it "return the source card" do
          Card::Env.params[:sourcebox] = 'true'
          company = get_a_sample_company
          url_key = company.cardname.url_key

          new_source_url = "#{ Card::Env[:protocol] }#{ Card::Env[:host] }/#{url_key }"
          new_sourcepage = Card.new :type_id=>Card::SourceID,:subcards=>{ '+Link' => {:content=> new_source_url}, '+File' =>{:type_id=>Card::FileID}, '+Text'=>{:type_id=>Card::BasicID,:content=>""} }
          expect(new_sourcepage).not_to be_valid
          expect(new_sourcepage.errors).to have_key :source
          expect(new_sourcepage.errors[:source]).to include(" can only be source type or valid URL.")
        end
      end
      context "a non exisiting card link" do
        it "return errors" do
          
          Card::Env.params[:sourcebox] = 'true'
         
          new_source_url = "#{ Card::Env[:protocol] }#{ Card::Env[:host] }/non_exisiting_card_1"

          new_sourcepage = Card.new :type_id=>Card::SourceID,:subcards=>{ '+Link' => {:content=> new_source_url}, '+File' =>{:type_id=>Card::FileID}, '+Text'=>{:type_id=>Card::BasicID,:content=>""} }
          expect(new_sourcepage).not_to be_valid
          expect(new_sourcepage.errors).to have_key :source
          expect(new_sourcepage.errors[:source]).to include(" does not exist.")

        end
      end
    end
    describe "creating a source in sourcebox" do
      context "while link is a card name" do
        it "returns source card " do
          source_card = create_page
          Card::Env.params[:sourcebox] = 'true'
          return_source_card = Card.create :type_id=>Card::SourceID,:subcards=>{ '+Link' => {:content=> source_card.name}, '+File' =>{:type_id=>Card::FileID}, '+Text'=>{:type_id=>Card::BasicID,:content=>""} }
          expect(return_source_card.name).to eq(source_card.name)
        end
        it "returns error" do
          Card::Env.params[:sourcebox] = 'true'
          return_source_card = Card.new :type_id=>Card::SourceID,:subcards=>{ '+Link' => {:content=> get_a_sample_company.name}, '+File' =>{:type_id=>Card::FileID}, '+Text'=>{:type_id=>Card::BasicID,:content=>""} }
          expect(return_source_card).not_to be_valid
          expect(return_source_card.errors).to have_key :source
          expect(return_source_card.errors[:source]).to include(" can only be source type or valid URL.")
        end
      end
      context "while link is a non existing card" do
        it "returns error " do
          Card::Env.params[:sourcebox] = 'true'
          return_source_card = Card.new :type_id=>Card::SourceID,:subcards=>{ '+Link' => {:content=> "this is not a exisiting card"}, '+File' =>{:type_id=>Card::FileID}, '+Text'=>{:type_id=>Card::BasicID,:content=>""} }
          expect(return_source_card).not_to be_valid
          expect(return_source_card.errors).to have_key :source
          expect(return_source_card.errors[:source]).to include(" does not exist.")

        end
      end
    end
  end
  describe "while rendering views" do 
    before do 
      login_as 'joe_user'
      @url = 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
      @source_page = create_page @url,{}
    end
    it "renders titled view with voting" do
      expect(@source_page.format.render_titled).to eq(@source_page.format.render_titled_with_voting)
    end

    it "renders open view with :custom_source_header to be true" do 
      expect(@source_page.format.render_open).to include(@source_page.format.render_header_with_voting)
    end

    it "renders header view with :custom_source_header to be true" do
      expect(@source_page.format.render_header  :custom_source_header=>true ).to include(@source_page.format.render_header_with_voting)
    end
    it "renders metric_import_link" do
      test_csv = File.open("#{Rails.root}/mod/wikirate_source/spec/set/type_plus_right/source/import_test.csv")
      sourcepage = Card.create! :type_id=>Card::SourceID,:subcards=>{'+File'=>{ :file=>test_csv,:type_id=>Card::FileID}}
      html = sourcepage.format.render_metric_import_link
      source_file = sourcepage.fetch :trait=>:file
      expect(html).to have_tag("a",:with=>{:href=>"/#{source_file.cardname.url_key}?view=import"},:text=>"Import to metric values")
    end
    describe "original_icon_link" do
      context "file source" do
        it "renders upload icon" do
          test_csv = File.open("#{Rails.root}/mod/wikirate_source/spec/set/type_plus_right/source/import_test.csv")
          sourcepage = Card.create! :type_id=>Card::SourceID,:subcards=>{'+File'=>{ :file=>test_csv,:type_id=>Card::FileID}}
          html = sourcepage.format.render_original_icon_link
          source_file = sourcepage.fetch :trait=>:file
          expect(html).to have_tag("a",:with=>{:href=>source_file.file.url}) do
            with_tag "i",:with=>{:class=>"fa fa-upload"}
          end
        end
      end
      context "link source" do
        it "renders globe icon" do
          html = @source_page.format.render_original_icon_link
          expect(html).to have_tag("a",:with=>{:href=>@url}) do
            with_tag "i",:with=>{:class=>"fa fa-globe"}
          end
        end
      end
      context "text source" do
        it "renders pencil icon" do
          new_sourcepage = Card.create! :type_id=>Card::SourceID,:subcards=>{'+Text'=>{:type_id=>Card::BasicID,:content=>"test text report"} }
          html = new_sourcepage.format.render_original_icon_link
          text_source = new_sourcepage.fetch(:trait=>:text)
          expect(html).to have_tag("a",:with=>{:href=>"/#{text_source.cardname.url_key}"}) do
            with_tag "i",:with=>{:class=>"fa fa-pencil"}
          end
        
        end
      end
    end

  end
  
 
end
