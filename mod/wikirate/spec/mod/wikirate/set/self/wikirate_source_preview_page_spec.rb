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
  # describe "send feedback to CERTH" do
  #   before do
  #     @url = "http://google.com"
  #   end
  #   describe "send insufficient parameters" do
  #     it "handles no parameter" do 
  #       #no parameters
  #       result = @source_preview_page.format( :format=>:json)._render(:feedback)
  #       expect(result[:result]).to be false
  #     end
  #     it "handles no url" do
  #       Card::Env.params[:company] = "Apple"
  #       Card::Env.params[:topic] = "Natural Resource Use"
  #       Card::Env.params[:type] = "either"
  #       result = @source_preview_page.format( :format=>:json)._render(:feedback)
  #       expect(result[:result]).to be false

  #     end
  #     it "handles no company" do
  #      Card::Env.params[:url] = @url
  #       Card::Env.params[:topic] = "Natural Resource Use"
  #       Card::Env.params[:type] = "either"
  #       result = @source_preview_page.format( :format=>:json)._render(:feedback)
  #       expect(result[:result]).to be false

  #     end
  #     it "handles no topic" do
  #       Card::Env.params[:url] = @url
  #       Card::Env.params[:company] = "Apple"
  #       Card::Env.params[:type] = "either"
  #       result = @source_preview_page.format( :format=>:json)._render(:feedback)
  #       expect(result[:result]).to be false

  #     end
  #     it "handles no type" do
  #       Card::Env.params[:url] = @url
  #       Card::Env.params[:company] = "Apple"
  #       Card::Env.params[:topic] = "Natural Resource Use"
  #       result = @source_preview_page.format( :format=>:json)._render(:feedback)
  #       expect(result[:result]).to be false

  #     end
  #   end
  #   describe "send invalid parameters" do
  #     it "handles invalid company" do 
  #       Card::Env.params[:url] = @url
  #       Card::Env.params[:company] = "joe_user"
  #       Card::Env.params[:topic] = "Natural Resource Use"
  #       Card::Env.params[:type] = "either"
  #       result = @source_preview_page.format( :format=>:json)._render(:feedback)
  #       expect(result[:result]).to be false
  #     end
  #     it "handles invalid topic" do 
  #       Card::Env.params[:url] = @url
  #       Card::Env.params[:company] = "Apple"
  #       Card::Env.params[:topic] = "joe_user"
  #       Card::Env.params[:type] = "either"
  #       result = @source_preview_page.format( :format=>:json)._render(:feedback)
  #       expect(result[:result]).to be false
  #     end
  #     it "handles invalid type" do 
  #       Card::Env.params[:url] = @url
  #       Card::Env.params[:company] = "Apple"
  #       Card::Env.params[:topic] = "Natural Resource Use"
  #       Card::Env.params[:type] = "joe_user"
  #       result = @source_preview_page.format( :format=>:json)._render(:feedback)
  #       expect(result[:result]).to be false
  #     end
  #   end
  #   describe "normal cases" do
  #     it "handles either type" do 
  #       Card::Env.params[:url] = @url
  #       Card::Env.params[:company] = "Apple"
  #       Card::Env.params[:topic] = "Natural Resource Use"
  #       Card::Env.params[:type] = "either"
  #       result = @source_preview_page.format( :format=>:json)._render(:feedback)
  #       expect(result[:result]).to be true
  #       expect(result[:result_from_certh]).to eq(1)
  #     end
  #     it "handles company type" do 
  #       Card::Env.params[:url] = @url
  #       Card::Env.params[:company] = "Apple"
  #       Card::Env.params[:topic] = "Natural Resource Use"
  #       Card::Env.params[:type] = "company"
  #       result = @source_preview_page.format( :format=>:json)._render(:feedback)
  #       expect(result[:result]).to be true
  #       expect(result[:result_from_certh]).to eq(1)
  #     end
  #     it "handles topic type" do 
  #       Card::Env.params[:url] = @url
  #       Card::Env.params[:company] = "Apple"
  #       Card::Env.params[:topic] = "Natural Resource Use"
  #       Card::Env.params[:type] = "topic"
  #       result = @source_preview_page.format( :format=>:json)._render(:feedback)
  #       expect(result[:result]).to be true
  #       expect(result[:result_from_certh]).to eq(1)
  #     end
  #     it "handles relevant type" do 
  #       Card::Env.params[:url] = @url
  #       Card::Env.params[:company] = "Apple"
  #       Card::Env.params[:topic] = "Natural Resource Use"
  #       Card::Env.params[:type] = "relevant"
  #       result = @source_preview_page.format( :format=>:json)._render(:feedback)
  #       expect(result[:result]).to be true
  #       expect(result[:result_from_certh]).to eq(1)
  #     end
  #   end
  # end
end