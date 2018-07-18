describe Card::Set::Right::Image do
  describe "missing view" do
    context "'`type`+missing_image_card' is set" do
      before do
        file = File.open("#{Rails.root}/mod/wikirate/spec/set/right/image.jpg")
        @missing_image_card = Card.create! name: "user+missing_image_card",
                                           type_id: Card::ImageID, image: file
        @content_card = Card.create! name: "Joe, My Son",
                                     content: "{{joe user+image}}"
      end

      it "shows '`type`+missing_image_card'" do
        html = @content_card.format.render_content
        expect(html).to include(@missing_image_card.format.render_core)
      end

      it "renders based on args' home view" do
        html = @content_card.format.render_content home_view: :content
        expect(html).to include(@missing_image_card.format.render_core)
        expect(html).to have_tag(
          "div", with: { class: "RIGHT-missing_image_card" }
        )
      end
    end

    context "'`type`+missing_image_card' is not set" do
      it "shows original missing image while " do
        content_card = Card.create! name: "Joe, My Son",
                                    content: "{{joe user+image}}"
        html = content_card.format.render_content
        expect(html).to include(Card["missing image"].format.render_core)
      end
    end
  end
end
