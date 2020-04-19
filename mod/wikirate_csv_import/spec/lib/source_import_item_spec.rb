require_relative "import_item_spec_helper"

RSpec.describe SourceImportItem do
  include ImportItemSpecHelper

  ITEM_HASH = {
    wikirate_company: "Death Star",
    year: "1977",
    report_type: "Dark Report",
    source: "http://xckd.com",
    wikirate_title: "Death Star Source"
  }

  describe "#import_hash" do
    it "generates a valid import_hash" do
      item = validate
      expect(item.import_hash)
        .to include(
              type_id: Card::SourceID,
              subfields: a_hash_including(
                wikirate_company: "Death Star",
                file:  { remote_file_url: url, type_id: Card::FileID }
              )
            )
    end
  end

  describe "#import" do
    it "works with valid item_hash" do
      status = import.status_hash
      expect(status[:errors]).to be_blank
      expect(Card.fetch_type_id(status[:id])).to eq(Card::SourceID)
    end
  end

end