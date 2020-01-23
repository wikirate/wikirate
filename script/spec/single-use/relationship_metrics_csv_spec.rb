require_relative "../../single-use/relationship_import/relationship_metrics_csv"

RSpec.describe "relationship metric import" do
  let(:path) do
    File.expand_path "../single_relationship_metrics.csv", __FILE__
  end

  before do
    RelationshipMetricsCsvFile.new(path).import
  end

  it "creates designer" do
    expect(Card.exists?("Relationship Metric Folk")).to be true
  end

  describe "relationship metric" do
    let(:metric) { Card["Relationship Metric Folk+is Supplied By"] }

    it "exists" do
      expect(metric).to be_instance_of Card
    end

    it "has metric type 'Relationship'" do
      expect(metric.metric_type).to eq "Relationship"
    end

    it "has value type 'Category'" do
      expect(metric.value_type).to eq "Category"
    end

    it "has value options" do
      expect(metric.value_options)
        .to eq ["Tier 1 Supplier", "Tier 2 Supplier"]
    end
  end

  describe "inverse relationship metric" do
    let(:metric) { Card["Relationship Metric Folk+is Supplier Of"] }

    it "exists" do
      expect(metric).to be_instance_of Card
    end

    it "has metric type 'Inverse Relationship'" do
      expect(metric.metric_type).to eq "Inverse Relationship"
    end
  end
end
