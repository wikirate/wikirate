# -*- encoding : utf-8 -*-
require 'link_thumbnailer'


def create_webpage url,sourcebox
  _url = url
  _url = 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow' if !url
  Card::Env.params[:sourcebox] = sourcebox
  sourcepage = Card.create! :type_id=>Card::WebpageID,:subcards=>{ '+Link' => {:content=> _url} }
end
describe Card::Set::Self::Webpage do
  describe "get meta data of url" do
    
    it "should handle invalid url" do
      
      url = 'abcdefg'
      page_card = Card["Page"]
      Card::Env.params[:url] = url
      result = page_card.format( :format=>:json)._render(:metadata) 

      result_hash = JSON.parse(result)
      result_hash["title"].should == ""
      result_hash["description"].should == ""
      result_hash["error"].should == 'invalid url'
     
    end
    it "should handle empty url" do
      url = ''
      page_card = Card["Page"]
      Card::Env.params[:url] = url
      result = page_card.format( :format=>:json)._render(:metadata) 

      result_hash = JSON.parse(result)
      result_hash["title"].should == ""
      result_hash["description"].should == ""
      result_hash["error"].should == 'empty url'
    end

    it "should handle normal existing url " do
      url = 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
      sourcepage = create_webpage url,'true'

      page_card = Card["Page"]
      Card::Env.params[:url] = url
      result = page_card.format( :format=>:json)._render(:metadata) 

      result_hash = JSON.parse(result)
      Card.fetch("#{ sourcepage.name }+title").content.should == result_hash["title"]
      Card.fetch("#{ sourcepage.name }+description").content.should == result_hash["description"]
      result_hash["error"].empty?.should == true
    end

    it "should handle normal non existing url " do
      url = 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
      
      page_card = Card["Page"]
      Card::Env.params[:url] = url
      result = page_card.format( :format=>:json)._render(:metadata) 

      result_hash = JSON.parse(result)
      preview = LinkThumbnailer.generate(url)

      result_hash["title"].should == preview.title
      result_hash["description"].should == preview.description
      result_hash["error"].empty?.should == true
      
    end
    # it "uses the right context for content view" do
    #   sourcepage = create_webpage nil,'true'
    #   html = render_card :content,{:name=>sourcepage.name+"+a"}
    #   expect(html).to eq("+a")
    # end
    it "shows the link for view \"missing\"" do
      sourcepage = create_webpage nil,'true'
      html = render_card :missing,{:name=>sourcepage.name}
      expect(html).to eq(render_card :link,{:name=>sourcepage.name} )
    end
  end
end
