describe Card::Set::Type::Record do
  describe "#related_companies_with_year" do
    example "relationship metric" do
      card = Card.fetch "Jedi+more evil+SPECTRE"
      expect(card.related_companies_with_year)
        .to eq "Los_Pollos_Hermanos" => ["1977"]
    end

    example "inverse relationship metric" do
      card = Card.fetch "Jedi+less evil+Los_Pollos_Hermanos"
      expect(card.related_companies_with_year)
        .to eq "SPECTRE" => ["1977"], "Death_Star" => ["1977"]
    end
  end
end
