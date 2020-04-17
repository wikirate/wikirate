RSpec.describe MetricImportItem do
  ITEM_HASH = {
    question: "What are the company’s policies?",
    metric_type: "Researched", #{ map: true, type: :metric_type_type },

      # Metric Name Parts
    metric_designer: "Joe User", # TODO: map when we support multi-type mapping
    metric_title: "Policities",

    topic: "Force; Taming",
      # TODO: map when we support (optional) multi-value mapping

      # Rich-Text fields
    about: "about policies",
    methodology: "policy methodology",
    # Note: special html is added for certain content, eg
    #       "Note:" and "Sources:" are made bold

    value_type: "Category",

    value_options: "A;B;C",
    research_policy: "community",
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

  describe "#normalize_research_policy"

  describe "#import_hash" do
    it "generates arguments for card creation" do
      item = validate
      puts item.import_hash
      expect(item.import_hash)
        .to include(name: "Joe User+Policities",
                    type_id: Card::MetricID,
                    subfields: a_hash_including(
                      question: "What are the company’s policies?",
                      value_type: "Category",
                      value_options: "[[A]]\n[[B]]\n[[C]]",
                      #research_policy: { content: "Community Assessed",
                      #                   type_id: Card::PointerID },
#wikirate_topic: "[[Force]]\n[[Taming]]"
                    ))
    end
  end

  def item_hash args={}
    ITEM_HASH.merge args
  end

  def item_object hash=nil
    hash ||= item_hash
    described_class.new hash
  end

  def validate item_hash=nil
    item = item_object item_hash
    item.validate!
    item
  end

  def import item_hash=nil
    item = item_object item_hash
    item.import
    item
  end
end