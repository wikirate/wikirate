RSpec.describe Card::Set::Type::RelationshipImport do
  # below refer to the post-processing indices of the import csv
  # (note: subtract 2 from line number in relationship_import.csv
  # 1 for 0-based array indexing, 1 for the header)
  INDECES = {
    known: [9, 10], # company known, other fields mapped
    unknown: [4, 13, 14] # company unknown, other fields mapped
  }.freeze

  def card_subject
    Card["relationship import test"]
  end

  def import_indices key
    row_params = INDECES[key].each_with_object({}) { |i, h| h[i] = true }
    Card::Env.with_params(import_rows: row_params) do
      with_delayed_jobs do
        card_subject.update!({})
      end
    end
  end

  def check_relationship_cards
    object_companies.each do |object_company_name|
      expect(Card[answer_name, object_company_name]).to be_present
    end
  end

  context "with known company" do
    let :answer_name do
      "Jedi+more evil+Death Star+2000"
    end

    let :object_companies do
      ["Google Inc", "SPECTRE"]
    end

    it "correctly updates counts for answer with multiple relationships" do
      import_indices :known

      check_relationship_cards
      expect(Card[answer_name].value).to eq("2")
      expect(Card["Jedi+less evil+SPECTRE+2000"].value).to eq("1")
    end
  end

  context "with unknown company" do
    let :answer_name do
      "Jedi+more evil+New Company+2017"
    end

    let :object_companies do
      ["Google Inc", "SPECTRE", "Sony"]
    end

    def mapping map_type, mappings, &block
      Card::Env.with_params mapping: { map_type => mappings }, &block
    end

    it "autoadds" do
      mapping :company, "New Company" => "AutoAdd", "Sony" => "AutoAdd" do
        card_subject.import_map_card.update!({})
      end
      expect(card_subject.status.count(:ready)).to eq(5)
    end

    example "it correctly updates counts for answer with multiple relationships" do
      mapping :company, "New Company" => "AutoAdd", "Sony" => "AutoAdd" do
        card_subject.import_map_card.update!({})
      end

      import_indices :unknown
      check_relationship_cards
      expect(Card[answer_name].value).to eq("3")
      expect(Card["Jedi+less evil+SPECTRE+2017"].value).to eq("1")
    end
  end
end
