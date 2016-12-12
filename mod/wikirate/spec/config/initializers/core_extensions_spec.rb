describe CoreExtensions do
  context String do
    it "tests whether a string represents a number" do
      expect("6".number?).to eq(true)
      expect("Yomama".number?).to eq(false)
    end
  end

  context CoreExtensions::PersistentIdentifier do
    it "converts into a cardname" do
      expect(:wagn_bot.name).to eq("WikiRate Bot")
    end

    it "converts into a card" do
      expect(Card::ClaimID.card.id).to eq(Card::ClaimID)
      expect(:claim.card.id).to eq(Card::ClaimID)
      expect(:claim.card.key).to eq(:claim.cardname.key)
    end
  end
end
