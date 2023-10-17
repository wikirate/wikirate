RSpec.describe Card::Set::Type::Reference do
  def card_subject_name
    "Reference 0000001"
  end
  check_views_for_errors

  context "a dataset with an alteration." do
    let(:card) {Card.fetch("Reference 0000001")}
    it "shows who did the adaptation in Rich Text." do
      expect(card.format.render(:rich_text_attrib)).to match(/adaptation by Joe User/)
    end
    it "shows who did the adaptation in Plain Text." do
      expect(card.format.render(:plain_text_attrib)).to match(/adaptation by Joe User/)
    end
    it "shows who did the adaptation in HTML." do
      expect(card.format.render(:html_attrib)).to match(/adaptation by Joe User/)
    end
  end

  context "a metric from a community-assessed metric." do
    let(:card) {Card.fetch("Reference 0000002")}
    it "includes community credit in Rich Text." do
      expect(card.format.render(:rich_text_attrib)).to match(/Wikirate's community/)
    end
    it "includes community credit in Plain Text." do
      expect(card.format.render(:plain_text_attrib)).to match(/Wikirate's community/)
    end
    it "includes community credit in HTML." do
      expect(card.format.render(:html_attrib)).to match(/Wikirate&#39;s community/)
    end
  end

  context "a metric from a designer-assessed metric." do
    let(:card) {Card.fetch("Reference 0000003")}
    it "does not include community credit in Rich Text." do
      expect(card.format.render(:rich_text_attrib)).to_not match(/Wikirate's community/)
    end
    it "does not include community credit in Plain Text." do
      expect(card.format.render(:plain_text_attrib)).to_not match(/Wikirate's community/)
    end
    it "does not include community credit in HTML." do
      expect(card.format.render(:html_attrib)).to_not match(/Wikirate's community/)
    end
  end

  context "an answer." do
    let(:card) {Card.fetch("Jedi+disturbances in the Force+Death Star+2001")}
    it "does include Death Star in Rich Text." do
      expect(card.format.render(:rich_text_attrib)).to match(/(Death Star, 2001)/)
    end
    it "does include Death Star in Plain Text." do
      expect(card.format.render(:plain_text_attrib)).to match(/(Death Star, 2001)/)
    end
    it "does include Death Star in HTML." do
      expect(card.format.render(:html_attrib)).to match(/(Death Star, 2001)/)
    end
  end
end
