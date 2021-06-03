RSpec.describe Card::MetricQuery do
  describe "designer filter" do
    it "works with id" do
      results = described_class.new(designer_id: "Jedi".card_id).run

      expect(results.map { |c| c.metric_designer }.uniq).to eq(["Jedi"])
    end

    it "works without id" do
      results = described_class.new(designer: "Jedi").run
      expect(results.map { |c| c.metric_designer }.uniq).to eq(["Jedi"])
    end
  end
end
