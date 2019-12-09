RSpec.describe Card::Set::Right::Wikipedia do
  def wikipedia_field company=nil, new={}
    company ||= "created_company"
    Card.fetch "#{company}+#{:wikipedia.cardname}", new: new
  end

  describe "event: validate_and_normalize_wikipedia_title" do
    def validated_wikipedia_field company, new={}
      field = wikipedia_field company, new
      field.validate_and_normalize_wikipedia_title
      field
    end

    context "when card is new and content is blank" do
      it "normalizes company when company exists on wikipedia" do
        expect(validated_wikipedia_field("Monsters_Inc").content).to eq "Monsters, Inc."
      end

      it "leaves content blank when company does not exist on wikipedia" do
        expect(validated_wikipedia_field("bookmarked company").content).to be_blank
      end
    end

    context "when content is not blank" do
      def wikipedia_title_content content
        validated_wikipedia_field nil, content: content
      end

      it "normalizes valid titles" do
        expect(wikipedia_title_content("monsters Inc").content).to eq "Monsters, Inc."
      end

      it "adds an error on invalid titles" do
        expect(wikipedia_title_content("muensterzINC").errors[:content])
          .to include("invalid Wikipedia Title")
      end

      it "catches disallowed characters" do
        expect(wikipedia_title_content("me > you").errors[:content])
          .to include(/Characters not allowed/)
      end

      it "handles full wikipedia urls" do
        expect(
          wikipedia_title_content("https://en.wikipedia.org/wiki/Bay_of_Bengal").content
        ).to eq("Bay of Bengal")
      end
    end
  end
  
  describe "#wikipedia_extract" do
    it "should pull extract from wikipedia" do
      field = wikipedia_field "Death Star", content: "Death Star"
      expect(field.wikipedia_extract).to match(/fictional mobile space/)
    end
  end
end