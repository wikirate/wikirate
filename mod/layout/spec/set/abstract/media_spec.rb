describe Card::Set::Abstract::Media do
  describe "#image_with_text" do
    subject do
      Card["Samsung"].format_with_set(described_class, :html)
    end

    it "uses +image by default" do
      expect(subject.text_with_image)
        .to have_tag :div, with: { class: "media" } do
          with_tag "img[src*='/files/']", with: { alt: "Samsung+image" }
        end
    end

    it "takes image card name as image" do
      expect(subject.text_with_image(image: "*logo"))
        .to have_tag :div, with: { class: "media" } do
          with_tag "img[src*='/files/']", with: { alt: "*logo" }
        end
    end

    it "takes image card object as image" do
      expect(subject.text_with_image(image: Card["*logo"]))
        .to have_tag :div, with: { class: "media" } do
          with_tag "img[src*='/files/']", with: { alt: "*logo" }
        end
    end

    it "handles size argument" do
      expect(subject.text_with_image(size: :small))
        .to have_tag :div, with: { class: "media" } do
          with_tag "img[src*='small']"
        end
    end
  end
end
