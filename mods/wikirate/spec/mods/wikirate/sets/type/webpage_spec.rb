# -*- encoding : utf-8 -*-
require 'link_thumbnailer'

describe Card::Set::Type::Webpage do
  describe "while creating a Page" do
    it "should add title,description" do
      login_as 'joe_user'	
        url = 'http://www.google.com'
        #Card::Env.params[:sourcebox] = url
        sourcepage = Card.create! :type_id=>Card::WebpageID,:subcards=>{ '+Link' => {'content'=> "#{url}"} }
        preview = LinkThumbnailer.generate(url)

        Card.fetch("#{ sourcepage.name }+title").content.should == preview.title
        Card.fetch("#{ sourcepage.name }+description").content.should == preview.description
     
    end
  end
end
