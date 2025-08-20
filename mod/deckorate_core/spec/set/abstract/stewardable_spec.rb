RSpec.describe Card::Set::Abstract::Stewarder do
  let(:user) { Card["Joe User"] }
  let(:metric) { Card["Jedi+deadliness"] }

  describe "#stewarded_metric_ids" do
    it "finds designed metrics" do
      expect(user.stewarded_metric_ids.first.card.metric_designer_id).to eq(user.id)
    end

    it "finds explicitly stewarded metrics" do
      metric.steward_card.update! content: user.name
      expect(user.stewarded_metric_ids).to include(metric.id)
    end
  end
end
