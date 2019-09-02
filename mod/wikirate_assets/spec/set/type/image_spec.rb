RSpec.describe Card::Set::Type::Image do
  describe "missing view" do
    def new_image_view view
      Card.new(type_id: Card::ImageID, name: "TestImage").format.render view
    end

    it "is NOT wrapped when rendered from core" do
      expect(new_image_view(:core)).not_to match(/unknown-view/)
    end

    it "is wrapped when rendered directly" do
      expect(new_image_view(:unknown)).to match(/unknown-view/)
    end

    it "is wrapped when rendered from content" do
      expect(new_image_view(:content)).to match(/unknown-view/)
    end
  end
end
