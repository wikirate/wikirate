describe Card::Set::MetricType::Relationship do
  describe "create" do
    before do
      create "Joe User+bigger than",
             type_id: Card::MetricID,
             subfields: {
               metric_type: "Relationship",
               inverse_title: "smaller than"
             }
    end

    let(:metric) { Card["Joe User+bigger than"] }
    let(:inverse_metric) { Card["Joe User+smaller than"] }

    it "creates metric" do
      expect(metric).to be_instance_of Card
      expect(metric.type_name).to eq "Metric"
      expect(metric.relationship?).to be true
      expect(metric.metric_type).to eq "Relationship"
    end

    it "creates inverse metric" do
      expect(inverse_metric).to be_instance_of Card
      expect(inverse_metric.type_name).to eq "Metric"
      expect(inverse_metric.relationship?).to be true
      expect(inverse_metric.metric_type).to eq "Inverse Relationship"
    end

    it "links relationship metric to inverse" do
      expect(metric.inverse_card).to eq inverse_metric
    end

    it "links inverse relationship metric to relationship metric" do
      expect(inverse_metric.inverse_card).to eq metric
    end

    it "links inverse titles" do
      expect(Card["bigger than+inverse"].item_names)
        .to contain_exactly "smaller than"

      expect(Card["smaller than+inverse"].item_names)
        .to contain_exactly "bigger than"
    end
  end
end
