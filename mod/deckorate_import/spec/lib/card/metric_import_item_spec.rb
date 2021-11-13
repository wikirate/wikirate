require_relative "import_item_spec_helper"

RSpec.describe Card::MetricImportItem do
  include Card::ImportItemSpecHelper

  let(:metric_name) { "Joe User+Policities" }

  let :default_item_hash do
    {
      question: "What are the company’s policies?",
      metric_type: "Researched", # { map: true, type: :metric_type_type },

      # Metric Name Parts
      metric_designer: "Joe User", # TODO: map when we support multi-type mapping
      metric_title: "Policities",

      wikirate_topic: "Force; Taming",
      # TODO: map when we support (optional) multi-value mapping

      # Rich-Text fields
      about: "Note: about policies\n",
      methodology: "policy methodology",
      # Note: special html is added for certain content, eg
      #       "Note:" and "Sources:" are made bold

      value_type: "Category",

      value_options: "A;B;C",
      research_policy: "Community Assessed",
      # supports "community", "designer", or full name, eg "Community Assessed"
      report_type: nil
    }
  end

  describe "#validate" do
    it "confirms valid item is 'ready'" do
      item = validate
      expect(item.errors).to be_blank
      expect(item.status[:status]).to eq(:ready)
    end
  end

  describe "#import" do
    it "imports new metric card" do
      item = import
      expect(item.errors).to be_blank
      expect(Card.fetch_type_id(metric_name)).to eq(Card::MetricID)
    end

    it "works for score" do
      item = import(metric_type: "Score",
                    scorer: "Joe Admin",
                    metric_title: "RM",
                    value_type: "Number")
      expect(item.errors).to be_blank
    end
  end

  it "handles unpublished" do
    import unpublished: "true"
    expect(Card[metric_name]).to be_unpublished
  end

  describe "#import_hash" do
    it "generates arguments for card creation" do
      item = validate
      expect(item.import_hash)
        .to include(name: metric_name,
                    type_id: Card::MetricID,
                    subfields: a_hash_including(
                      question: "What are the company’s policies?",
                      value_type: "Category"
                    ))
    end

    it "handles unmapped multi-value fields" do
      item = validate
      expect(subfield(item, :value_options)).to eq(content: %w[A B C])
    end

    it "handles multi-value fields" do
      item = validate
      expect(subfield(item, :wikirate_topic)).to eq(content: %w[Force Taming])
    end
  end

  describe "#format_html" do
    it "makes 'Note' bold" do
      item = validate
      expect(subfield(item, :about))
        .to eq("<em><strong>Note:</strong> about policies</em><br>\n")
    end
  end

  def subfield item, column
    item.import_hash[:subfields][column]
  end
end
