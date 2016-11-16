describe Card::Set::TypePlusRight::MetricValue::CheckedBy do
  let(:metric_value_card) { Card["joe_user+researched+death_star+1977"] }
  describe "check value" do
    it "checks the metric value" do
      Card::Env.params["checked"] = "true"
      cb_card = metric_value_card.fetch trait: :checked_by, new: {}
      cb_card.save!
      cb_card.update_attributes! subcards: {}
      expect(cb_card.item_names.size).to eq(1)
      expect(cb_card.item_names).to include("Joe User")
    end
  end
  describe "uncheck value" do
    it "checks the metric value" do
      Card::Env.params["uncheck"] = "true"
      cb_card = metric_value_card.fetch trait: :checked_by,
                                        new: { content: "[[Joe User]]" }
      cb_card.save!
      cb_card.update_attributes! subcards: {}
      expect(cb_card.item_names.size).to eq(0)
    end
  end
end
