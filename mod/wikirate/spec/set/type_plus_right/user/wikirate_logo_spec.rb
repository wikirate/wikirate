describe Card::Set::TypePlusRight::User::WikirateLogo do
  describe "user's logo" do
    context "rendering +logo" do
      it "renders user+image with args" do
        file = File.open("#{Rails.root}/mod/wikirate/spec/set/right/image.jpg")
        @missing_image_card = Card.create! :name=>"joe user+image",:type_id=>Card::ImageID,:image=>file

        content_card = Card.create! :name=>"Joe, My Son",:content=>"{{joe user+logo|core;size:small}}"

        html = content_card.format.render_content
        expect(html).to include(Card["joe user+image"].format.render_core(:size=>:small))
      end
    end
  end
end