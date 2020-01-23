require_relative "../../single-use/metric_import/metric_csv_row"
require_relative "../../single-use/metric_import/metrics_csv_file"

RSpec.describe "metric import" do
  before do
    path = File.expand_path "../metrics.csv", __FILE__
    Card::Auth.as_bot do
      MetricsCsvFile.new(path).import
    end
  end
  context "import money metric" do
    let :metric do
      Card["Higher Education Statistics Agency (HESA)+Total income (£)"]
    end

    it "creates metric" do
      expect(metric).to be_instance_of Card
    end

    it "creates designer" do
      expect(Card["Higher Education Statistics Agency (HESA)"].type_name).to eq "Research Group"
    end

    it "creates title" do
      expect(Card["Total income (£)"].type_name).to eq "Metric Title"
    end

    it "creates value type" do
      expect(metric.field(:value_type).content).to eq "Money"
    end

    it "creates unit" do
      expect(metric.field(:unit).content).to eq "£"
    end

    it "does not create value options" do
      expect(metric.field(:value_options)).to eq nil
    end

    it "creates research policy" do
      expect(metric.field(:research_policy).content).to eq "Community"
    end

    it "creates methodology" do
      expect(metric.field(:methodology).content).to include "This data will be provided by HESA"
    end

    it "question" do
      expect(metric.field(:question).content).to eq "What is the higher education providers total income?"
    end
  end

  context "import category metric" do
    let :metric do
      Card["Fairtrade Foundation+Fairtrade Status"]
    end

    it "creates metric" do
      expect(metric).to be_instance_of Card
    end

    it "creates value type" do
      expect(metric.field(:value_type).content).to eq "Category"
    end

    it "does not create unit" do
      expect(metric.field(:unit)).to be_falsey
    end

    it "creates research policy" do
      expect(metric.field(:research_policy).content).to eq "Community"
    end

    it "creates value options" do
      expect(metric.field(:value_options).content)
        .to eq ["No", "Working towards status", "Yes"].to_pointer_content
    end

    it "creates topic tags" do
      expect(metric.field(:wikirate_topic).content)
        .to eq ["Fairtrade", "supply chain"].to_pointer_content
    end
  end
end
