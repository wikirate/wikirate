require_relative "import_item_spec_helper"

RSpec.describe Card::RelationshipImportItem do
  include Card::ImportItemSpecHelper

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
    example "creates relationship answer card with valid data", as_bot: true do
      import
      expect_card(item_name).to exist
      answer = Card[item_name.left]
      expect(answer.type_id).to eq(Card::MetricAnswerID)
      expect(answer.value).to eq("1")
      expect(answer.inverse_answer_id.card.value).to eq("1")
    end

    example "increments relationship counts", as_bot: true do
      answer_card = Card[item_name(year: "1977").left]
      expect(answer_card.answer.numeric_value).to eq(2)
      import year: "1977"
      expect(answer_card.answer.numeric_value).to eq(3)
    end
  end

  context "with unknown company" do
    def default_map
      map = super
      map[:wikirate_company] =
        map.delete(:subject_company).merge(map.delete(:object_company))
      map
    end

    it "gets 'failed' status" do
      # because ImportManager doesn't have corrections. otherwise would be "not ready"
      # needs better testing!
      item = validate object_company: "Mos Eisley"
      expect(item.status.item_hash(0)[:status]).to eq(:failed)
    end

    it "succeeds with auto add" do
      co = "Kuhl Co"
      item = item_object object_company: co
      map = default_map
      map[:wikirate_company][co] = "AutoAdd"
      item.corrections = map
      item.import

      expect(Card[co].type_id).to eq(Card::WikirateCompanyID)
    end
  end
end
