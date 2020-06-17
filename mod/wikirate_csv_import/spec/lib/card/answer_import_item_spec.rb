require_relative "import_item_spec_helper"

RSpec.describe Card::AnswerImportItem do
  include Card::ImportItemSpecHelper

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

  describe "#default_header_map" do
    it "uses order specified in @columns hash" do
      expect(described_class.default_header_map).to(
        eq(metric: 0, wikirate_company: 1, year: 2, value: 3, source: 4, comment: 5)
      )
    end
  end

  describe "#map_headers" do
    let :header_map do
      { metric: 5, wikirate_company: 1, year: 3, value: 0, source: 2, comment: 4 }
    end

    it "interprets headings in any order" do
      array = %w[Value Company Source Year Comment Metric]
      expect(described_class.map_headers(array)).to eq(header_map)
    end

    it "handles variable capitalization and pluralization" do
      array = %w[VALUE companies SOURCES Years comment metrics]
      expect(described_class.map_headers(array)).to eq(header_map)
    end

    it "allows optional columns to be missing" do
      array = %w[Value Company Source Year Metric]
      map = header_map.merge comment: nil, metric: 4
      expect(described_class.map_headers(array)).to eq(map)
    end

    it "fails if required columns are be missing" do
      array = %w[Value Company Source Year Comment]
      expect { described_class.map_headers(array) }
        .to raise_error(/Metric column is missing/)
    end

    it "ignores extra columns" do
      array = %w[Value Mama Company Why Source No Year Cookie Comment Today Metric]
      expect(described_class.map_headers(array)).to(
        eq(metric: 10, wikirate_company: 2, year: 6, value: 0, source: 4, comment: 8)
      )
    end
  end

  describe "corrections" do
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

  describe "#import" do
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

    context "with conflicts" do
      it "leaves existing values when skipping" do
        item = item_object(wikirate_company: "Monster Inc", year: "1977")
        expect(item.conflict_strategy).to eq(:skip)
        item.import
        answer = Card["Jedi+disturbances in the Force+Monster Inc+1977"]
        expect(answer.value).to eq("no") # existing value is "no"
      end

      it "overrides existing values when overriding" do
        overriding do
          import wikirate_company: "Monster Inc", year: "1977"
          answer = Card["Jedi+disturbances in the Force+Monster Inc+1977"]
          expect(answer.value).to eq("yes") # existing value is "no"
        end
      end

      it "appends comments when overriding" do
        import comment: "Firstly"
        overriding { import comment: "Secondly" }
        expect(Card[item_name, :discussion].content).to match(/Firstly.*Secondly/m)
      end
    end
  end
end
