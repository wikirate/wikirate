require_relative "import_item_spec_helper"

RSpec.describe AnswerImportItem do
  include ImportItemSpecHelper

  let :default_item_hash do
    {
      metric: "Jedi+disturbances in the Force",
      wikirate_company: "Google Inc",
      year: "2017",
      value: "yes",
      source: :opera_source.cardname,
      comment: ""
    }
  end

  let(:item_name_parts) { %i[metric wikirate_company year] }

  specify "answer doesn't exist" do
    expect(Card[item_name]).not_to be_a Card
  end

  describe "corrections" do
    def default_map
      default_item_hash.each_with_object({}) do |(column, val), hash|
        next if column.in? %i[value comment]
        hash[column] = { val => Card.fetch_id(val) }
      end
    end

    it "handles auto adding company" do
      co = "Kuhl Co"
      item = item_object wikirate_company: co
      item.corrections = default_map.merge(wikirate_company: { co => "AutoAdd" })
      item.import

      expect(Card[co].type_id).to eq(Card::WikirateCompanyID)
    end

    it "handles auto adding source" do
      src = "http://url.com"
      item = item_object source: src
      item.corrections = default_map.merge(source: { src => "AutoAdd" })
      item.validate

      expect(item.import_hash["+source"])
        .to include(content: [src], trigger_in_action: :auto_add_source)
    end
  end

  describe "#execute_import" do
    example "creates answer card with valid data", as_bot: true do
      import
      expect_card(item_name).to exist
    end

    example "updates existing answer" do
      args = { wikirate_company: "Death Star", year: "2000" } # existing answer
      import args
      expect(Card[item_name(args)]).to be_real
    end

    # example "existing source" do
    #   import existing_source do
    #     expect(Card[item_name].source_card.first]).to be_real
    #   end
    # end

    example "not a metric" do
      expect(import(metric: "Never Met Rick").errors)
        .to contain_exactly("invalid metric: Never Met Rick")
    end

    example "invalid metric", as_bot: true do
      expect(import(metric: "A").errors).to contain_exactly("invalid metric: A")
    end

    example "invalid year", as_bot: true do
      expect(import(year: "A").errors).to contain_exactly("invalid year: A")
    end

    # NOTE: this is not caught by import validation but by card validation
    example "invalid value", as_bot: true do
      expect(import(value: "5").errors).to contain_exactly(/invalid option\(s\): 5/)
    end

    it "aggregates errors" do
      expect(import(year: "Google Inc", metric: "2007").errors)
        .to contain_exactly "invalid metric: 2007", "invalid year: Google Inc"
    end
  end
end
