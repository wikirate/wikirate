RSpec.describe Card::Set::Type::RelationshipImport do
  # below refer to the post-processing indeces of the import csv
  # (note: subtract 2 from line number in relationship_import.csv
  # 1 for 0-based array indexing, 1 for the header)
  INDECES = {
    known: [9, 10], # company known, other fields mapped
    unknown: [4, 13, 14] # company unknown, other fields mapped
  }.freeze

  def card_subject
    Card["relationship import test"]
  end

  def import_indeces key
    indeces = INDECES[key]
    row_params = indeces.each_with_object({}) { |i, h| h[i] = true }
    Card::Env.with_params(import_rows: row_params) do
      Delayed::Worker.delay_jobs = true
      card_subject.update!({})
      Delayed::Worker.new.work_off
    end
  end

  def check_relationship_answer_cards
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

    it "correctly updates counts for answers with multiple relationships" do
      import_indeces :known

      check_relationship_answer_cards
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
      mapping :wikirate_company, "New Company" => "AutoAdd", "Sony" => "AutoAdd" do
        card_subject.import_map_card.update!({})
      end
      expect(card_subject.status.count(:ready)).to eq(5)
    end

    example "it correctly updates counts for answers with multiple relationships" do
      mapping :wikirate_company, "New Company" => "AutoAdd", "Sony" => "AutoAdd" do
        card_subject.import_map_card.update!({})
      end

      import_indeces :unknown
      check_relationship_answer_cards
      expect(Card[answer_name].value).to eq("3")
      expect(Card["Jedi+less evil+SPECTRE+2017"].value).to eq("1")
    end
  end
end
