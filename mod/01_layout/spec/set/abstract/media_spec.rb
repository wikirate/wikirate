describe Card::Set::Abstract::Media do
  describe "#image_with_text" do
    subject do
      Card["Samsung"].format_with_set(Card::Set::Abstract::Media, :html, &:text_with_image)
    end

    it "uses +image by default" do
      log_html subject
      is_expected.to have_tag :div, with: { class: "media" } do
        with_tag "img[src*='/files/']", with: { alt: "Samsung+image" }
      end
    end

    it "takes image card name as image" do
      Card["Samsung"].format_with_set(Card::Set::Abstract::Media, :html) do |format|
        expect(format.text_with_image image: "*logo").to have_tag :div, with: { class: "media" } do
          with_tag "img[src*='/files/']", with: { alt: "*logo" }
        end
      end
    end

    it "takes image card object as image" do
      Card["Samsung"].format_with_set(Card::Set::Abstract::Media, :html) do |format|
        expect(format.text_with_image image: Card["*logo"]).to have_tag :div, with: { class: "media" } do
          with_tag "img[src*='/files/']", with: { alt: "*logo" }
        end
      end
    end

    it "handles size argument" do
      Card["Samsung"].format_with_set(Card::Set::Abstract::Media, :html) do |format|
        expect(format.text_with_image size: :small).to have_tag :div, with: { class: "media" } do
          with_tag "img[src*='small']"
        end
      end
    end
  end
end
