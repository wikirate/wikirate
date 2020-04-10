RSpec.describe Card::Set::Right::ImportMap do
  def card_subject
    @card_subject ||= Card["answer import file"].import_map_card
  end

  describe "#map" do
    it "should return a hash based on json content" do
      expect(card_subject.map[:wikirate_company]["Monster Inc"]).to eq("Monster Inc.")
    end

    it "should handle blank content" do
      card_subject.content = ""
      expect(card_subject.map).to be_a(Hash)
    end

  end


end
