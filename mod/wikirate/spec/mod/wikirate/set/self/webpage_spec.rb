# -*- encoding : utf-8 -*-
require 'link_thumbnailer'

describe Card::Set::Self::Webpage do
  describe "get meta data of url" do
    
    it "should handle invalid url" do
      
      url = 'abcdefg'
      page_card = Card["Page"]
      Card::Env.params[:url] = url
      result = page_card.format( :format=>:json)._render(:metadata) 

      result_hash = JSON.parse(result)
      expect(result_hash["title"]).to eq("")
      expect(result_hash["description"]).to eq("")
      expect(result_hash["error"]).to eq('invalid url')
     
    end
    it "should handle empty url" do
      url = ''
      page_card = Card["Page"]
      Card::Env.params[:url] = url
      result = page_card.format( :format=>:json)._render(:metadata) 

      result_hash = JSON.parse(result)
      expect(result_hash["title"]).to eq("")
      expect(result_hash["description"]).to eq("")
      expect(result_hash["error"]).to eq('empty url')
    end

    it "should handle normal existing url " do
      url = 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
      sourcepage = create_page_with_sourcebox url,{},'true'

      page_card = Card["Page"]
      Card::Env.params[:url] = url
      result = page_card.format( :format=>:json)._render(:metadata) 

      result_hash = JSON.parse(result)
      Card.fetch("#{ sourcepage.name }+title").content.should == result_hash["title"]
      Card.fetch("#{ sourcepage.name }+description").content.should == result_hash["description"]
      expect(result_hash["error"].empty?).to be true
    end

    it "should handle normal non existing url " do
      url = 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
      
      page_card = Card["Page"]
      Card::Env.params[:url] = url
      result = page_card.format( :format=>:json)._render(:metadata) 

      result_hash = JSON.parse(result)
      preview = LinkThumbnailer.generate(url)

      expect(result_hash["title"]).to eq(preview.title)
      expect(result_hash["description"]).to eq(preview.description)
      expect(result_hash["error"].empty?).to be true
      
    end
    # it "uses the right context for content view" do
    #   sourcepage = create_page_with_sourcebox nil,'true'
    #   html = render_card :content,{:name=>sourcepage.name+"+a"}
    #   expect(html).to eq("+a")
    # end
    it "shows the link for view \"missing\"" do
      sourcepage = create_page_with_sourcebox nil,{},'true'
      html = render_card :missing,{:name=>sourcepage.name}
      expect(html).to eq(render_card :link,{:name=>sourcepage.name} )
    end
  end
end
