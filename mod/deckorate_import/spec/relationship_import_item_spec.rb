RSpec.describe Card::RelationshipImportItem do
  include Cardio::ImportItemSpecHelper

  let :default_item_hash do
    {
      metric: "Jedi+more evil",
      subject_company: "Death Star",
      object_company: "Google Inc",
      year: "2017",
      value: "yes",
      source: :opera_source.cardname,
      comment: ""
    }
  end

  let(:item_name_parts) { %i[metric subject_company year object_company] }

  specify "answer doesn't exist" do
    expect(Card[item_name]).to be_nil
  end

  describe "#import" do
    example "creates relationship card with valid data", as_bot: true do
      import
      expect_card(item_name).to exist
      answer = Card[item_name.left]
      expect(answer.type_id).to eq(Card::AnswerID)
      expect(answer.value).to eq("1")
      expect(Card[item_name].inverse_answer_id.card.value).to eq("1")
    end

    example "increments relationship counts", as_bot: true do
      answer_card = Card[item_name(year: "1977").left]
      expect(answer_card.answer.numeric_value).to eq(2)
      import year: "1977"
      expect(answer_card.answer.reload.numeric_value).to eq(3)
    end
  end

  context "with unknown company" do
    let(:unknown_co) { "Kuhl Co" }

    it "gets 'failed' status" do
      # because ImportManager doesn't have mapping. otherwise would be "not ready"
      # needs better testing!
      item = validate object_company: unknown_co
      expect(item.status[:status]).to eq(:failed)
    end

    it "handles auto adding company" do
      described_class.auto_add :company, unknown_co
      expect(Card[unknown_co].type_id).to eq(Card::CompanyID)
    end
  end
end
