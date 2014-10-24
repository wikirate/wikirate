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

        Card.fetch("#{ sourcepage.name }+title").content.should == preview.title
        Card.fetch("#{ sourcepage.name }+description").content.should == preview.description
     
    end
    it "should create website card for new website" do
        url = 'http://thisisanewwebsite.com/abc'
        Card::Env.params[:sourcebox] = 'true'
        sourcepage = Card.create! :type_id=>Card::WebpageID,:subcards=>{ '+Link' => {:content=> url} }

        Card["thisisanewwebsite.com"].real?.should==true

    end
    it "should handle empty url" do
        url = ''
        Card::Env.params[:sourcebox] = 'true'
        sourcepage = Card.new :type_id=>Card::WebpageID,:subcards=>{ '+Link' => {:content=> url} }
        sourcepage.should_not be_valid
        sourcepage.errors.should have_key :link
        sourcepage.errors[:link].include?("is empty").should==true
    end
    # it "includes name context in content view" do 
    #   url = 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
    #   Card::Env.params[:sourcebox] = 'true'
    #   sourcepage = Card.create! :type_id=>Card::WebpageID,:subcards=>{ '+Link' => {:content=> url} }
    #   binding.pry
    #   sourcepage.format.render_content
    # end
    it "should handle duplicated url " do
      url = 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
      Card::Env.params[:sourcebox] = 'true'
      firstsourcepage = Card.create! :type_id=>Card::WebpageID,:subcards=>{ '+Link' => {:content=> url} }
      secondsourcepage = Card.create! :type_id=>Card::WebpageID,:subcards=>{ '+Link' => {:content=> url} }
      firstsourcepage.name.should == secondsourcepage.name
    end
  end
end
