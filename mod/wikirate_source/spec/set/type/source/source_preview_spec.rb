# -*- encoding : utf-8 -*-
require 'link_thumbnailer'

describe Card::Set::Type::Source do
  
  describe "company_and_topic_detail and source_preview_options view" do
    describe "sources from CERTH" do
      before do 
        @nonexisting_url = "http://nonexistingpage.com"
        @url = "http://existingpage.com"
        @new_page_card = Card.new :type_id=>Card::SourceID
      end
      describe "source exists in wikirate" do
        before do
          @existing_source = create_page_with_sourcebox @url,{"+Company"=>"Apple Inc.","+Topic"=>"Natural Resource Use"},'false'
        end
        it "shows nothing in the company_and_topic_detail if no company and topic in url" do 
          Card::Env.params[:url] = @nonexisting_url
          
          result = @new_page_card.format._render_preview

          expect(result).to match(%{<div class="company-name ">[ \\n]+<\/div>})
          expect(result).to match(%{<div class="topic-name ">[ \\n]+<\/div>})
        end
        it "shows the edit dropbox button, options for existing sources if company and topic match wikirate's one" do
          company = "Apple Inc."
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
          expect(result).to include(%{<a href="/#{@existing_source.cardname.url_key}?slot[structure]=source_company_and_topic&view=edit" id="company-and-topic-detail-link" class="">})

        end
        it "hides the edit dropbox button if company and topic do not match wikirate's one" do
          company = "Amazon"
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
          company = "Amazon"
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
        @company = "Amazon"
        @topic = "Natural Resource Use"
        @existing_source = create_page_with_sourcebox @url,{"+Company"=>@company,"+Topic"=>@topic},'false'
      end
      it "shows options for existing sources" do 
        Card::Env.params[:url] = @url
        result = @existing_source.format._render_preview
        expect(result).to have_tag("div", :with=>{:class=>"menu-options"}) do
          with_tag "a",  :with=>{:class=>"show-link-in-popup", :href=>"/#{@existing_source.cardname.url_key}+source_claim_list?slot[hide]=header"}
          with_tag "a",  :with=>{:class=>"show-link-in-popup", :href=>"/#{@existing_source.cardname.url_key}+discussion?slot[hide]=header"}
          with_tag "a",  :with=>{:class=>"show-link-in-popup", :href=>"/#{@existing_source.cardname.url_key}?slot[structure]=source_structure&view=edit&slot[hide]=header"}
          with_tag "a",  :with=>{:href=>@existing_source.fetch(:trait=>:wikirate_link).content}  
        end
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
        expect(result).to include(%{<a href="/#{@existing_source.cardname.url_key}?slot[structure]=source_company_and_topic&view=edit" id="company-and-topic-detail-link" class="">})
      end
      it "shows add topic if topic does not exist" do
        new_url = "http://www.google.com/nonexistingwikiratewebpage"
        existing_source = create_page_with_sourcebox new_url,{"+Company"=>"Apple Inc."},'false'
        Card::Env.params[:url] = new_url
        
        company = "Apple Inc."
        company_link_name = Card[company].cardname.url_key

        result = existing_source.format._render_preview
        #show company and topic
        expect(result).to include(%{<a href="#{company_link_name}" target="_blank">})
        expect(result).to include(%{<span class="company-name">#{company}</span>})
        expect(result).to include(%{<a id='add-topic-link' href='#' >Add Topic</a>})
        #hide dropdown button
        expect(result).to include(%{<a href="/#{existing_source.cardname.url_key}?slot[structure]=source_company_and_topic&view=edit" id="company-and-topic-detail-link" class="">})
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
        expect(result).to include(%{<a href="/#{existing_source.cardname.url_key}?slot[structure]=source_company_and_topic&view=edit" id="company-and-topic-detail-link" class="">})
      end
    end
  end
 
end
