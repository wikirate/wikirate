require_relative "import_item_spec_helper"

RSpec.describe SourceImportItem do
  include ImportItemSpecHelper

  TEST_URL = "https://decko.org/Home.txt".freeze

  let :default_item_hash do
    {
      wikirate_company: "Death Star",
      year: "1977",
      report_type: "Dark Report",
      wikirate_link: TEST_URL,
      wikirate_title: "Death Star Source"
    }
  end

  describe "#import_hash" do
    it "generates a valid import_hash" do
      item = validate
      expect(item.import_hash)
        .to include(
          type_id: Card::SourceID,
          subfields: a_hash_including(
            wikirate_company: { content: ["Death Star"] },
            wikirate_link: TEST_URL
          )
        )
    end
  end

  describe "#import" do
    it "works with valid item_hash", as_bot: true do
      status = import.status_hash
      expect(status[:errors]).to be_blank
      imported_card = Card[status[:id]]
      expect(imported_card.type_id).to eq(Card::SourceID)
      expect(imported_card.fetch(:file).id).to be_present
    end
  end
end
