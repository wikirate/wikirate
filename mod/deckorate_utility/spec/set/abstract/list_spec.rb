RSpec.describe Card::Set::Abstract::List do
  describe "unique_items?" do
    it "true by default for all wikirate lists" do
      expect(Card.new(type: :list)).to be_unique_items
    end
  end
end
