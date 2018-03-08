RSpec.describe Card::Set::Type::Record do
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

  describe "json view #related_companies_with_year" do
    let(:companies) do
      Card["Clean_Clothes_Campaign+Supplier of+Los Pollos Hermanos"]
        .format(:json).render_related_companies_with_year
    end

    specify do
      expect(JSON.parse(companies)).to eq  "Monster_Inc" => ["1977"],
                                           "SPECTRE" => %w[1977 2000]
    end
  end
end
