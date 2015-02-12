# -*- encoding : utf-8 -*-
require 'link_thumbnailer'

describe Card::Set::Type::Webpage do
  describe "while creating a Page" do
    before do
      login_as 'joe_user' 
    end
    it "should add title,description" do
      
      url = 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
      Card::Env.params[:sourcebox] = 'true'
      sourcepage = Card.create! :type_id=>Card::WebpageID,:subcards=>{ '+Link' => {:content=> url} }
      preview = LinkThumbnailer.generate(url)

      expect(Card.fetch("#{ sourcepage.name }+title").content).to eq(preview.title)
      expect(Card.fetch("#{ sourcepage.name }+description").content).to eq(preview.description)
     
    end
    it "should handle empty url" do
        url = ''
        Card::Env.params[:sourcebox] = 'true'
        sourcepage = Card.new :type_id=>Card::WebpageID,:subcards=>{ '+Link' => {:content=> url} }
        expect(sourcepage).not_to be_valid
        expect(sourcepage.errors).to have_key :link
        expect(sourcepage.errors[:link]).to include("is empty")
    end
    describe "while creating duplicated source on claim page" do
      it "should return exisiting url" do
        url = 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
        Card::Env.params[:sourcebox] = 'true'
        firstsourcepage = Card.create :type_id=>Card::WebpageID,:subcards=>{ '+Link' => {:content=> url} }
        secondsourcepage = Card.create :type_id=>Card::WebpageID,:subcards=>{ '+Link' => {:content=> url} }
        expect(firstsourcepage.name).to eq(secondsourcepage.name)
      end
    end
    describe "while creating duplicated source on source page" do
      it "should show error" do
        url = 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
        
        firstsourcepage = Card.create :type_id=>Card::WebpageID,:subcards=>{ '+Link' => {:content=> url} }
        secondsourcepage = Card.new :type_id=>Card::WebpageID,:subcards=>{ '+Link' => {:content=> url} }
        
        expect(secondsourcepage).not_to be_valid
        expect(secondsourcepage.errors).to have_key :link
        expect(secondsourcepage.errors[:link]).to include("exists already. <a href='/#{firstsourcepage.name}'>Visit the source.</a>")

       
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
  describe "company_and_topic_detail and source_preview_options view" do
    describe "sources from CERTH" do
      before do 
        @nonexisting_url = "http://nonexistingpage.com"
        @url = "http://existingpage.com"
        @new_page_card = Card.new :type_id=>Card::WebpageID
      end
      describe "source exists in wikirate" do
        before do
          @existing_source = create_page_with_sourcebox @url,{"+Company"=>"Apple","+Topic"=>"Natural Resource Use"},'false'
        end
        it "shows nothing in the company_and_topic_detail if no company and topic in url" do 
          Card::Env.params[:url] = @nonexisting_url
          
          result = @new_page_card.format._render_preview

          expect(result).to match(%{<div class="company-name ">[ \\n]+<\/div>})
          expect(result).to match(%{<div class="topic-name ">[ \\n]+<\/div>})
        end
        it "shows the edit dropbox button, options for existing sources if company and topic match wikirate's one" do
          company = "Apple"
          topic = "Natural Resource Use"
          Card::Env.params[:url] = @url
          Card::Env.params[:company] = company
          Card::Env.params[:topic] = topic
          
          topic_link_name = Card[topic].cardname.url_key
          company_link_name = Card[company].cardname.url_key

          result = @new_page_card.format._render_preview
          #show company and topic
          expect(result).to include(%{<a href="#{company_link_name}" target="_blank">})
          expect(result).to include(%{<span class="company-name">#{company}</span>})
          expect(result).to include(%{<a href="#{topic_link_name}" target="_blank">})
          expect(result).to include(%{<span class="topic-name">#{topic}</span>})
          #show dropdown button
          expect(result).to include(%{<a href="/#{@existing_source.name}?slot[structure]=source_company_and_topic&view=edit" id="company-and-topic-detail-link" class="">})

          
          expect(result).to include("Source Details")
          expect(result).to include("Direct Link")
          expect(result).to include("Make a Claim")
          expect(result).to include(%{<div id="claim-count">})

        end
        it "hides the edit dropbox button if company and topic do not match wikirate's one" do
          company = "Ahold"
          topic = "Natural Resource Use"
          Card::Env.params[:url] = @url
          Card::Env.params[:company] = company
          Card::Env.params[:topic] = topic
          
          topic_link_name = Card[topic].cardname.url_key
          company_link_name = Card[company].cardname.url_key

          result = @new_page_card.format._render_preview
          #show company and topic
          expect(result).to include(%{<a href="#{company_link_name}" target="_blank">})
          expect(result).to include(%{<span class="company-name">#{company}</span>})
          expect(result).to include(%{<a href="#{topic_link_name}" target="_blank">})
          expect(result).to include(%{<span class="topic-name">#{topic}</span>})
          #hide dropdown button
          expect(result).to include(%{<a href="/?slot[structure]=source_company_and_topic&view=edit" id="company-and-topic-detail-link" class="no-dropdown">})

          
          expect(result).to include("Irrelevant")
          expect(result).to include("Relevant")
        end
      end
      describe "source does not exist in wikirate" do
        it "shows company and topic from url, hide the edit drop down button" do
          company = "Ahold"
          topic = "Natural Resource Use"
          Card::Env.params[:url] = @nonexisting_url
          Card::Env.params[:company] = company
          Card::Env.params[:topic] = topic
          

          topic_link_name = Card[topic].cardname.url_key
          company_link_name = Card[company].cardname.url_key

          result = @new_page_card.format._render_preview
          #show company and topic
          expect(result).to include(%{<a href="#{company_link_name}" target="_blank">})
          expect(result).to include(%{<span class="company-name">#{company}</span>})
          expect(result).to include(%{<a href="#{topic_link_name}" target="_blank">})
          expect(result).to include(%{<span class="topic-name">#{topic}</span>})
          #hide dropdown button
          
          expect(result).to include(%{<a href="/?slot[structure]=source_company_and_topic&view=edit" id="company-and-topic-detail-link" class="no-dropdown">})

          
          expect(result).to include("Irrelevant")
          expect(result).to include("Relevant")

        end
      end
    end
    describe "sources from wikirate" do
      before do
        @url = "http://existingpage.com"
        @company = "Ahold"
        @topic = "Natural Resource Use"
        @existing_source = create_page_with_sourcebox @url,{"+Company"=>@company,"+Topic"=>@topic},'false'
      end
      it "shows options for existing sources" do 
        
        
        Card::Env.params[:url] = @url
        

        result = @existing_source.format._render_preview
        expect(result).to include("Source Details")
        expect(result).to include("Direct Link")
        expect(result).to include("Make a Claim")
        expect(result).to include(%{<div id="claim-count">})
      end
      it "shows dropdown button and company and topic" do
        Card::Env.params[:url] = @url
        

        topic_link_name = Card[@topic].cardname.url_key
        company_link_name = Card[@company].cardname.url_key

        result = @existing_source.format._render_preview
        #show company and topic
        expect(result).to include(%{<a href="#{company_link_name}" target="_blank">})
        expect(result).to include(%{<span class="company-name">#{@company}</span>})
        expect(result).to include(%{<a href="#{topic_link_name}" target="_blank">})
        expect(result).to include(%{<span class="topic-name">#{@topic}</span>})
        #hide dropdown button
        expect(result).to include(%{<a href="/#{@existing_source.name}?slot[structure]=source_company_and_topic&view=edit" id="company-and-topic-detail-link" class="">})
      end
      it "shows add topic if topic does not exist" do
        new_url = "http://www.google.com/nonexistingwikiratewebpage"
        existing_source = create_page_with_sourcebox new_url,{"+Company"=>"Apple"},'false'
        Card::Env.params[:url] = new_url
        
        company = "Apple"
        company_link_name = Card[company].cardname.url_key

        result = existing_source.format._render_preview
        #show company and topic
        expect(result).to include(%{<a href="#{company_link_name}" target="_blank">})
        expect(result).to include(%{<span class="company-name">#{company}</span>})
        expect(result).to include(%{<a id='add-topic-link' href='#' >Add Topic</a>})
        #hide dropdown button
        expect(result).to include(%{<a href="/#{existing_source.name}?slot[structure]=source_company_and_topic&view=edit" id="company-and-topic-detail-link" class="">})
      end
      it "shows add company if topic does not exist" do
        new_url = "http://www.google.com/nonexistingwikiratewebpage"
        existing_source = create_page_with_sourcebox new_url,{"+Topic"=>"Natural Resource Use"},'false'
        Card::Env.params[:url] = new_url
        topic = "Natural Resource Use"
        topic_link_name = Card[topic].cardname.url_key

        result = existing_source.format._render_preview
        #show company and topic
        expect(result).to include(%{<a id='add-company-link' href='#' >Add Company</a>})
        expect(result).to include(%{<a href="#{topic_link_name}" target="_blank">})
        expect(result).to include(%{<span class="topic-name">#{topic}</span>})
        #hide dropdown button
        expect(result).to include(%{<a href="/#{existing_source.name}?slot[structure]=source_company_and_topic&view=edit" id="company-and-topic-detail-link" class="">})
      end
    end
  end
 
end
