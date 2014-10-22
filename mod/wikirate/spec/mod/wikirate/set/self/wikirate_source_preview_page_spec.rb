describe Card::Set::All::Wikirate do
  describe "while check iframable" do
    it "should return true for a iframable website" do
    
      url = 'http://wikirate.org'
      source_preview_page = Card["source preview page"]
      Card::Env.params[:url] = url
      result = source_preview_page.format( :format=>:json)._render(:check_iframable) 
      result[:result].should == true
     
    end
    it "should return false for non iframble website" do
      url = 'http://www.google.com'
      source_preview_page = Card["source preview page"]
      Card::Env.params[:url] = url
      result = source_preview_page.format( :format=>:json)._render(:check_iframable) 
      result[:result].should == false
    end
    it "should return false for non sense website" do
      url = 'helloworld'
      source_preview_page = Card["source preview page"]
      Card::Env.params[:url] = url
      result = source_preview_page.format( :format=>:json)._render(:check_iframable) 
      result[:result].should == false
    end
    it "should return false for empty website" do
      source_preview_page = Card["source preview page"] 
      result = source_preview_page.format( :format=>:json)._render(:check_iframable) 
      result[:result].should == false
    end
  end
  describe "while check and get source" do
    it "should return existing source" do
      #create source
      url = 'http://thisisanewwebsite.com/abc11111'    
      sourcepage = create_webpage url,'true'
    
      source_preview_page = Card["source preview page"]
      Card::Env.params[:url] = url
      result = source_preview_page.format( :format=>:json)._render(:check_source) 
      
      result[:result].should == true
      result[:source].should == sourcepage.name
      
    end
    it "should return false for non existing source" do
      #create source
      binding.pry
      url = 'http://thisisanewwebsite.com/abc11111mustnotbeexistright'
      source_preview_page = Card["source preview page"]
      Card::Env.params[:url] = url
      result = source_preview_page.format( :format=>:json)._render(:check_source) 
      result[:result].should == false
    end
  end
end