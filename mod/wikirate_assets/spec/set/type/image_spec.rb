RSpec.describe Card::Set::Type::Image do
  describe "missing view" do
    before do
      @file = File.open("#{Rails.root}/mod/wikirate_assets/spec/set/right/image.jpg")
      @missing_card = Card["missing image"]
    end

    it "shows missing view because of denied" do
      image_card = Card.create! name: "TestImage", type_id: Card::ImageID,
                                image: @file
      missing_image = image_card.format.subformat(@missing_card)._render_core

      image_card_format = image_card.format
      image_card_format.instance_variable_set "@denied_view", :core

      expect(image_card_format.render_missing).to eq(missing_image)
    end

    it "shows missing view normally" do
      image_card = Card.create! name: "TestImage", type_id: Card::ImageID,
                                image: @file
      missing_image = image_card.format.subformat(@missing_card)._render_core
      html = image_card.format.render_missing
      expect(html).to include(missing_image)
    end
  end
end
