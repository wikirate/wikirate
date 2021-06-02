RSpec.describe Card::MetricQuery do
  describe "designer filter" do
    it "should work without id" do
      results = described_class.new(designer: "Jedi").run
      expect(results.map { |c| c.name.right }).to include("disturbances in the Force")
    end
  end
end
