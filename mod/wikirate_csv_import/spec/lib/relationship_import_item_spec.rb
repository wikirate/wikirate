require_relative "import_item_spec_helper"

RSpec.describe RelationshipImportItem do
  include ImportItemSpecHelper

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

  describe "#execute_import" do
    example "creates relationship answer card with valid data", as_bot: true do
      import
      expect_card(item_name).to exist
    end
  end
end
