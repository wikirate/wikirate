describe Card::Set::All::Wikirate do
  before do
    @source_preview_page = Card["source preview page"]
  end
  describe "while check iframable" do
    it "should return true for a iframable website" do
    
      url = 'http://wikirate.org'
   
      Card::Env.params[:url] = url
      result = @source_preview_page.format( :format=>:json)._render(:check_iframable) 
      expect(result[:result]).to be true
     
    end
    it "should return false for non iframble website" do
      url = 'http://www.google.com'
      
      Card::Env.params[:url] = url
      result = @source_preview_page.format( :format=>:json)._render(:check_iframable) 
      expect(result[:result]).to be false
    end
    it "should return false for non sense website" do
      url = 'helloworld'
      
      Card::Env.params[:url] = url
      result = @source_preview_page.format( :format=>:json)._render(:check_iframable) 
      expect(result[:result]).to be false
    end
    it "should return false for empty website" do
      
      result = @source_preview_page.format( :format=>:json)._render(:check_iframable) 
      expect(result[:result]).to be false
    end
  end
  describe "while check and get source" do
    it "should return existing source" do
      #create source
      url = 'http://thisisanewwebsite.com/abc11111'    
      sourcepage = create_webpage url,'true'
    
      
      Card::Env.params[:url] = url
      result = @source_preview_page.format( :format=>:json)._render(:check_source) 
      
      expect(result[:result]).to be true
      expect(result[:source]).to eq(sourcepage.name)
      
    end
    it "should return false for non existing source" do
      #create source
      url = 'http://thisisanewwebsite.com/abc11111mustnotbeexistright'
      
      Card::Env.params[:url] = url
      result = @source_preview_page.format( :format=>:json)._render(:check_source) 
      expect(result[:result]).to be false
    end
  end
  it "returns correct user id" do
    result = @source_preview_page.format( :format=>:json)._render(:get_user_id) 
    expect(result[:id]).to eq(JOE_USER_ID)
  end
  describe "company_and_topic_detail and source_preview_options view" do
    describe "sources from CERTH" do
      before do 
        @nonexisting_url = "http://nonexisitingpage.com"
        @url = "http://exisitingpage.com"
      end
      describe "source exists in wikirate" do
        before do
          @existing_source = create_webpage @url,false,"Apple","Natural Resource Use"
        end
        it "shows nothing in the company_and_topic_detail if exisiting source does not have company or topic" do 
          new_url = "http://www.google.com/nonexisitingwikiratewebpage"
          existing_source = create_webpage new_url,false
          Card::Env.params[:url] = new_url
          Card::Env.params[:fromcerth] = "true"

          result = @source_preview_page.format._render(:company_and_topic_detail) 

          expect(result).to match(%{<div class="company-name ">[ \\n]+<\/div>})
          expect(result).to match(%{<div class="topic-name ">[ \\n]+<\/div>})
        end
        it "shows nothing in the company_and_topic_detail if no company and topic in url" do 
          Card::Env.params[:url] = @nonexisting_url
          Card::Env.params[:fromcerth] = "true"

          result = @source_preview_page.format._render(:company_and_topic_detail) 

          expect(result).to match(%{<div class="company-name ">[ \\n]+<\/div>})
          expect(result).to match(%{<div class="topic-name ">[ \\n]+<\/div>})
        end
        it "shows the edit dropbox button, options for existing sources if company and topic match wikirate's one" do
          company = "Apple"
          topic = "Natural Resource Use"
          Card::Env.params[:url] = @url
          Card::Env.params[:company] = company
          Card::Env.params[:topic] = topic
          Card::Env.params[:fromcerth] = "true"

          result = @source_preview_page.format._render(:company_and_topic_detail) 
          #show company and topic
          expect(result).to include(%{<a href="#{company}" target="_blank"><span class="company-name">#{company}</span></a>})
          expect(result).to include(%{<a href="#{topic}" target="_blank"><span class="topic-name">#{topic}</span></a>})
          #show dropdown button
          expect(result).to include(%{<a href="#" id="company-and-topic-detail-link" style="">})

          result = @source_preview_page.format._render(:source_preview_options) 
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
          Card::Env.params[:fromcerth] = "true"

          result = @source_preview_page.format._render(:company_and_topic_detail) 
          #show company and topic
          expect(result).to include(%{<a href="#{company}" target="_blank"><span class="company-name">#{company}</span></a>})
          expect(result).to include(%{<a href="#{topic}" target="_blank"><span class="topic-name">#{topic}</span></a>})
          #hide dropdown button
          expect(result).to include(%{<a href="#" id="company-and-topic-detail-link" style="display:none;">})

          result = @source_preview_page.format._render(:source_preview_options) 
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
          Card::Env.params[:fromcerth] = "true"

          result = @source_preview_page.format._render(:company_and_topic_detail) 
          #show company and topic
          expect(result).to include(%{<a href="#{company}" target="_blank"><span class="company-name">#{company}</span></a>})
          expect(result).to include(%{<a href="#{topic}" target="_blank"><span class="topic-name">#{topic}</span></a>})
          #hide dropdown button
          expect(result).to include(%{<a href="#" id="company-and-topic-detail-link" style="display:none;">})

          result = @source_preview_page.format._render(:source_preview_options) 
          expect(result).to include("Irrelevant")
          expect(result).to include("Relevant")

        end
      end
    end
    describe "sources from wikirate" do
      before do
        @url = "http://exisitingpage.com"
        @company = "Ahold"
        @topic = "Natural Resource Use"
        @existing_source = create_webpage @url,false,@company,@topic
      end
      it "shows options for exisiting sources" do 
        
        
        Card::Env.params[:url] = @url
        Card::Env.params[:fromcerth] = "false"

        result = @source_preview_page.format._render(:source_preview_options) 
        expect(result).to include("Source Details")
        expect(result).to include("Direct Link")
        expect(result).to include("Make a Claim")
        expect(result).to include(%{<div id="claim-count">})
      end
      it "shows dropdown button and company and topic" do
        Card::Env.params[:url] = @url
        Card::Env.params[:fromcerth] = "false"

        result = @source_preview_page.format._render(:company_and_topic_detail) 
        #show company and topic
        expect(result).to include(%{<a href="#{@company}" target="_blank"><span class="company-name">#{@company}</span></a>})
        expect(result).to include(%{<a href="#{@topic}" target="_blank"><span class="topic-name">#{@topic}</span></a>})
        #hide dropdown button
        expect(result).to include(%{<a href="#" id="company-and-topic-detail-link" style="">})
      end
      it "shows add topic if topic does not exist" do
        new_url = "http://www.google.com/nonexisitingwikiratewebpage"
        existing_source = create_webpage new_url,false,"Apple"
        Card::Env.params[:url] = new_url
        Card::Env.params[:fromcerth] = "false"

        result = @source_preview_page.format._render(:company_and_topic_detail) 
        #show company and topic
        expect(result).to include(%{<a href="Apple" target="_blank"><span class="company-name">Apple</span></a>})
        expect(result).to include(%{<a id='add-topic-link' href='#' >Add Topic</a>})
        #hide dropdown button
        expect(result).to include(%{<a href="#" id="company-and-topic-detail-link" style="">})
      end
      it "shows add company if topic does not exist" do
        new_url = "http://www.google.com/nonexisitingwikiratewebpage"
        existing_source = create_webpage new_url,false,nil,"Natural Resource Use"
        Card::Env.params[:url] = new_url
        Card::Env.params[:fromcerth] = "false"

        result = @source_preview_page.format._render(:company_and_topic_detail) 
        #show company and topic
        expect(result).to include(%{<a id='add-company-link' href='#' >Add Company</a>})
        expect(result).to include(%{<a href="Natural Resource Use" target="_blank"><span class="topic-name">Natural Resource Use</span></a>})
        #hide dropdown button
        expect(result).to include(%{<a href="#" id="company-and-topic-detail-link" style="">})
      end
    end
  end
  describe "source_name view" do
    it "returns correct source name for url" do 
      url = "http://www.google.com/exisitingwikiratewebpage"
      existing_source = create_webpage url,false
      Card::Env.params[:url] = url
      result = @source_preview_page.format._render(:source_name) 
      expect(result).to eq(existing_source.name)
    end
    it "returns '' for non exisiting url" do 
      Card::Env.params[:url] = "http://www.google.com/nonexisitingwikiratewebpage"
      result = @source_preview_page.format._render(:source_name) 
      expect(result).to eq("")
    end
  end
  describe "send feedback to CERTH" do
    before do
      @url = "http://google.com"
    end
    describe "send insufficient parameters" do
      it "handles no parameter" do 
        #no parameters
        result = @source_preview_page.format( :format=>:json)._render(:feedback)
        expect(result[:result]).to be false
      end
      it "handles no url" do
        Card::Env.params[:company] = "Apple"
        Card::Env.params[:topic] = "Natural Resource Use"
        Card::Env.params[:type] = "either"
        result = @source_preview_page.format( :format=>:json)._render(:feedback)
        expect(result[:result]).to be false

      end
      it "handles no company" do
       Card::Env.params[:url] = @url
        Card::Env.params[:topic] = "Natural Resource Use"
        Card::Env.params[:type] = "either"
        result = @source_preview_page.format( :format=>:json)._render(:feedback)
        expect(result[:result]).to be false

      end
      it "handles no topic" do
        Card::Env.params[:url] = @url
        Card::Env.params[:company] = "Apple"
        Card::Env.params[:type] = "either"
        result = @source_preview_page.format( :format=>:json)._render(:feedback)
        expect(result[:result]).to be false

      end
      it "handles no type" do
        Card::Env.params[:url] = @url
        Card::Env.params[:company] = "Apple"
        Card::Env.params[:topic] = "Natural Resource Use"
        result = @source_preview_page.format( :format=>:json)._render(:feedback)
        expect(result[:result]).to be false

      end
    end
    describe "send invalid parameters" do
      it "handles invalid company" do 
        Card::Env.params[:url] = @url
        Card::Env.params[:company] = "joe_user"
        Card::Env.params[:topic] = "Natural Resource Use"
        Card::Env.params[:type] = "either"
        result = @source_preview_page.format( :format=>:json)._render(:feedback)
        expect(result[:result]).to be false
      end
      it "handles invalid topic" do 
        Card::Env.params[:url] = @url
        Card::Env.params[:company] = "Apple"
        Card::Env.params[:topic] = "joe_user"
        Card::Env.params[:type] = "either"
        result = @source_preview_page.format( :format=>:json)._render(:feedback)
        expect(result[:result]).to be false
      end
      it "handles invalid type" do 
        Card::Env.params[:url] = @url
        Card::Env.params[:company] = "Apple"
        Card::Env.params[:topic] = "Natural Resource Use"
        Card::Env.params[:type] = "joe_user"
        result = @source_preview_page.format( :format=>:json)._render(:feedback)
        expect(result[:result]).to be false
      end
    end
    describe "normal cases" do
      it "handles either type" do 
        Card::Env.params[:url] = @url
        Card::Env.params[:company] = "Apple"
        Card::Env.params[:topic] = "Natural Resource Use"
        Card::Env.params[:type] = "either"
        result = @source_preview_page.format( :format=>:json)._render(:feedback)
        expect(result[:result]).to be true
        expect(result[:result_from_certh]).to eq(1)
      end
      it "handles company type" do 
        Card::Env.params[:url] = @url
        Card::Env.params[:company] = "Apple"
        Card::Env.params[:topic] = "Natural Resource Use"
        Card::Env.params[:type] = "company"
        result = @source_preview_page.format( :format=>:json)._render(:feedback)
        expect(result[:result]).to be true
        expect(result[:result_from_certh]).to eq(1)
      end
      it "handles topic type" do 
        Card::Env.params[:url] = @url
        Card::Env.params[:company] = "Apple"
        Card::Env.params[:topic] = "Natural Resource Use"
        Card::Env.params[:type] = "topic"
        result = @source_preview_page.format( :format=>:json)._render(:feedback)
        expect(result[:result]).to be true
        expect(result[:result_from_certh]).to eq(1)
      end
      it "handles relevant type" do 
        Card::Env.params[:url] = @url
        Card::Env.params[:company] = "Apple"
        Card::Env.params[:topic] = "Natural Resource Use"
        Card::Env.params[:type] = "relevant"
        result = @source_preview_page.format( :format=>:json)._render(:feedback)
        expect(result[:result]).to be true
        expect(result[:result_from_certh]).to eq(1)
      end
    end
  end
end
