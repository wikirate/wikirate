require_relative "import_item_spec_helper"

RSpec.describe MetricImportItem do
  include ImportItemSpecHelper

  ITEM_HASH = {
    question: "What are the company’s policies?",
    metric_type: "Researched", # { map: true, type: :metric_type_type },

    # Metric Name Parts
    metric_designer: "Joe User", # TODO: map when we support multi-type mapping
    metric_title: "Policities",

    wikirate_topic: "Force; Taming",
    # TODO: map when we support (optional) multi-value mapping

    # Rich-Text fields
    about: "about policies",
    methodology: "policy methodology",
    # Note: special html is added for certain content, eg
    #       "Note:" and "Sources:" are made bold

    value_type: "Category",

    value_options: "A;B;C",
    research_policy: "Community Assessed",
    # supports "community", "designer", or full name, eg "Community Assessed"
    report_type: nil
  }

  describe "#validate" do
    it "confirms valid item is 'ready'" do
      item = validate
      expect(item.status_hash[:errors]).to be_blank
      expect(item.status_hash[:status]).to eq(:ready)
    end
  end

  describe "#import" do
    it "imports new metric card" do
      item = import
      expect(item.status_hash[:errors]).to be_blank
      expect(Card.fetch_type_id("Joe User+Policities")).to eq(Card::MetricID)
    end
  end

  # describe "#normalize_research_policy"

  describe "#import_hash" do
    it "generates arguments for card creation" do
      item = validate
      puts item.import_hash
      expect(item.import_hash)
        .to include(name: "Joe User+Policities",
                    type_id: Card::MetricID,
                    subfields: a_hash_including(
                      question: "What are the company’s policies?",
                      value_type: "Category"
                    ))
    end

    it "handles unmapped multi-value fields" do
      item = validate
      expect(item.import_hash[:subfields][:value_options])
        .to eq(content: %w[A B C])
    end

    it "handles multi-value fields" do
      item = validate
      expect(item.import_hash[:subfields][:wikirate_topic])
        .to eq(content: ["Force", "Taming"])
    end
  end
end
