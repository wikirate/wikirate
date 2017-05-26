require_relative "../../single-use/relationship_import/relationship_answers_csv"
require_relative "../../single-use/relationship_import/relationship_metrics_csv"

RSpec.describe "relationship answer import" do
  let(:metric_path) do
    File.expand_path "../single_relationship_metrics.csv", __FILE__
  end

  let(:answer_path) do
    File.expand_path "../single_relationship_answer.csv", __FILE__
  end

  before do
    RelationshipMetricsCSVFile.new(metric_path).import
    RelationshipAnswersCSVFile.new(answer_path).import
  end

  it "creates count" do
    card = Card["Relationship Metric Folk+is Supplied By+Adidas+2016+value"]
    expect(card).to be_truthy
    expect(card.content).to eq "2"
  end

  it "creates inverse count" do
    card = Card["Relationship Metric Folk+is Supplier Of+"\
                "Dhakarea Limited+2016+value"]
    expect(card.content).to eq "1"
  end

  it "creates answer" do
    card = Card["Relationship Metric Folk+is Supplied By"\
                "+Adidas+2016+Dhakarea Limited"]
    expect(card.content).to eq "Tier 1 Supplier"
  end
end
