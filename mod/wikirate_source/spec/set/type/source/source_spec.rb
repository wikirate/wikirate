# -*- encoding : utf-8 -*-
require 'link_thumbnailer'

describe Card::Set::Type::Source do
  describe "while creating a Page" do
    before do
      login_as 'joe_user' 
    end
    it "should add title,description" do
      
      url = 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
      Card::Env.params[:sourcebox] = 'true'
      sourcepage = Card.create! :type_id=>Card::SourceID,:subcards=>{ '+Link' => {:content=> url} }
      preview = LinkThumbnailer.generate(url)

      expect(Card.fetch("#{ sourcepage.name }+title").content).to eq(preview.title)
      expect(Card.fetch("#{ sourcepage.name }+description").content).to eq(preview.description)
     
    end
    it "should handle empty source" do
        url = ''
        Card::Env.params[:sourcebox] = 'true'
        sourcepage = Card.new :type_id=>Card::SourceID,:subcards=>{ '+Link' => {:content=> url} }
        expect(sourcepage).not_to be_valid
        expect(sourcepage.errors).to have_key :source
        
        expect(sourcepage.errors[:source]).to include("Please at least add one type of source")
    end
    describe "while creating duplicated source on claim page" do
      it "should return exisiting url" do
        url = 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
        Card::Env.params[:sourcebox] = 'true'
        firstsourcepage = Card.create :type_id=>Card::SourceID,:subcards=>{ '+Link' => {:content=> url} }
        secondsourcepage = Card.create :type_id=>Card::SourceID,:subcards=>{ '+Link' => {:content=> url} }
        expect(firstsourcepage.name).to eq(secondsourcepage.name)
      end
    end
    describe "while creating duplicated source on source page" do
      it "should show error" do
        url = 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
        
        firstsourcepage = Card.create :type_id=>Card::SourceID,:subcards=>{ '+Link' => {:content=> url} }
        secondsourcepage = Card.new :type_id=>Card::SourceID,:subcards=>{ '+Link' => {:content=> url} }
        
        expect(secondsourcepage).not_to be_valid
        expect(secondsourcepage.errors).to have_key :link
        expect(secondsourcepage.errors[:link]).to include("exists already. <a href='/#{firstsourcepage.name}'>Visit the source.</a>")

      end
    end
    describe "while creating a source with a file link" do 
      it "downloads it and saves as a file source" do
        pdf_url = "http://www.relacweb.org/conferencia/images/documentos/Hoteles_cerca.pdf"
        sourcepage = Card.create :type_id=>Card::SourceID,:subcards=>{ '+Link' => {:content=> pdf_url} }
        expect(sourcepage.errors).to be_empty
        expect(sourcepage.fetch(:trait=>:file)).to_not be_nil
        expect(sourcepage.fetch(:trait=>:wikirate_link)).to be_nil
      end
    end
    describe "while creating a source with a wikirate link" do 
      it "return the source card" do
        
        Card::Env.params[:sourcebox] = 'true'
        url = 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
        sourcepage = Card.create :type_id=>Card::SourceID,:subcards=>{ '+Link' => {:content=> url} }
        url_key = sourcepage.cardname.url_key
        new_source_url = "#{ Card::Env[:protocol] }#{ Card::Env[:host] }#{sourcepage.format.card_path url_key }"

        new_sourcepage = Card.create :type_id=>Card::SourceID,:subcards=>{ '+Link' => {:content=> new_source_url} }
        expect(sourcepage.name).to eq(new_sourcepage.name)

      end
    end
    describe "creating a source in sourcebox" do
      context "while link is a card name" do
        it "returns source card " do
          source_card = create_page
          Card::Env.params[:sourcebox] = 'true'
          return_source_card = Card.create :type_id=>Card::SourceID,:subcards=>{ '+Link' => {:content=> source_card.name} }
          expect(return_source_card.name).to eq(source_card.name)
        end
        it "returns error" do
          Card::Env.params[:sourcebox] = 'true'
          return_source_card = Card.new :type_id=>Card::SourceID,:subcards=>{ '+Link' => {:content=> get_a_sample_company.name} }
          expect(return_source_card).not_to be_valid
          expect(return_source_card.errors).to have_key :source
          expect(return_source_card.errors[:source]).to include(" can only be source type or valid URL.")
        end
      end
      context "while link is a non existing card" do
        it "returns source card " do
          Card::Env.params[:sourcebox] = 'true'
          return_source_card = Card.new :type_id=>Card::SourceID,:subcards=>{ '+Link' => {:content=> "this is not a exisiting card"} }
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
      url = 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
      @source_page = create_page url,{}
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

  end
  
 
end
