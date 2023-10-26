RSpec.describe Card::Set::Type::Reference do
  def card_subject_name
    "Reference 000000#{reference_number}"
  end

  let(:reference_number) { 1 }

  check_views_for_errors

  context "when it is a dataset with an alteration." do
    it "shows who did the adaptation in Rich Text." do
      expect_view(:rich_text_attrib).to match(/adaptation by Joe User/)
    end
    it "shows who did the adaptation in Plain Text." do
      expect_view(:plain_text_attrib).to match(/adaptation by Joe User/)
    end
    it "shows who did the adaptation in HTML." do
      expect_view(:html_attrib).to match(/adaptation by Joe User/)
    end
  end

  context "when metric is community assessed" do
    let(:reference_number) { 2 }

    it "includes community credit in Rich Text." do
      expect_view(:rich_text_attrib).to match(/Wikirate's community/)
    end
    it "includes community credit in Plain Text." do
      expect_view(:plain_text_attrib).to match(/Wikirate's community/)
    end
    it "includes community credit in HTML." do
      expect_view(:html_attrib).to match(/Wikirate&#39;s community/)
    end
  end

  context "when metric is designer assessed." do
    let(:reference_number) { 3 }

    it "does not include community credit in Rich Text." do
      expect_view(:rich_text_attrib).not_to match(/Wikirate's community/)
    end
    it "does not include community credit in Plain Text." do
      expect_view(:plain_text_attrib).not_to match(/Wikirate's community/)
    end
    it "does not include community credit in HTML." do
      expect_view(:html_attrib).not_to match(/Wikirate's community/)
    end
  end

  context "when it is an answer." do
    let(:reference_number) { 4 }

    it "does include company and year in Rich Text." do
      expect_view(:rich_text_attrib).to match(/(Death Star, 2001)/)
    end
    it "does include company and year in Plain Text." do
      expect_view(:plain_text_attrib).to match(/(Death Star, 2001)/)
    end
    it "does include company and year in HTML." do
      expect_view(:html_attrib).to match(/(Death Star, 2001)/)
    end
  end
end
