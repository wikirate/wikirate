shared_examples_for "viewable metric" do |metric_name|
  let(:metric) do
    Card[metric_name]
  end

  it "renders metric properties" do
    expect(metric.format.render_metric_properties).to lack_errors
  end
end

RSpec.describe Card::Set::Type::Metric do
  describe "Numeric type metric" do
    it_behaves_like "viewable metric", "Jedi+deadliness"
  end

  describe "Money type metric" do
    it_behaves_like "viewable metric", "Jedi+cost of planets destroyed"
  end

  describe "Category type metric" do
    it_behaves_like "viewable metric", "Jedi+disturbances in the Force"
  end

  describe "#numeric?" do
    it "returns true for number" do
      expect(sample_metric(:number).numeric?).to be true
    end

    it "returns true for money" do
      expect(sample_metric(:money).numeric?).to be true
    end

    it "returns false for category" do
      expect(sample_metric(:category).numeric?).to be false
    end

    it "returns false for free text" do
      expect(sample_metric(:free_text).numeric?).to be false
    end
  end

  context "when changing value type" do
    context "when from numeric", with_user: "Joe Admin" do
      let(:metric) { sample_metric(:number) }

      example "when to free text" do
        metric.value_type_card.update! content: "Free Text"
        expect(metric.value_type).to eq "Free Text"
      end

      example "when to category" do
        expect { metric.value_type_card.update! content: "Category" }
          .to raise_error ActiveRecord::RecordInvalid
      end

      example "when to money" do
        metric.value_type_card.update! content: "Money"
        expect(metric.value_type).to eq "Money"
      end
    end
  end

  context "when renaming" do
    it "expires the metric type", as_bot: true do
      newname = "Core+Western"
      original = Card["Core+Country"]
      original.format.render_open
      original.update! name: newname
      expect(Card["#{newname}+*metric_type"]).to be_a(Card)
    end
  end
end
