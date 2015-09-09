describe Card::Set::Type::Image do
  describe "missing view" do 
    it "shows missing view because of denied" do 

      
      image_card = Card.create! :name => "TestImage", :type_id=>Card::ImageID, :content => %{TestImage.jpg\nimage/jpeg\n12345}
      missing_image = image_card.format.subformat( Card['missing image'] )._render_core
      html = image_card.format.render_missing :denied_view=>:core

      expect(html).to eq(missing_image)
    end
    it "shows missing view normally" do 
      
      image_card = Card.create! :name => "TestImage", :type_id=>Card::ImageID, :content => %{TestImage.jpg\nimage/jpeg\n12345}
      missing_image = image_card.format.subformat( Card['missing image'] )._render_core
      html = image_card.format.render_missing 
      expect(html).to include(missing_image)

    end
  end
end
