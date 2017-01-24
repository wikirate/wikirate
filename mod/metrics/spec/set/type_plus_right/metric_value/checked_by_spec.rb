describe Card::Set::TypePlusRight::MetricValue::CheckedBy do
  let(:metric_value_card) { Card["joe_user+researched+death_star+1977"] }

  describe "check value" do
    before do
      Card::Env.params["set_flag"] = "checked"
      cb_card = metric_value_card.fetch trait: :checked_by, new: {}
      cb_card.save!
      cb_card.update_attributes! subcards: {}
      Card::Env.params.delete "set_flag"
    end

    it "checks the metric value" do
      expect(cb_card.item_names.size).to eq(1)
      expect(cb_card.item_names).to include("Joe User")
    end

    let(:checked_by) do
      metric_value_card.fetch trait: :checked_by
    end
    let(:double_checked) do
      Card.fetch("Joe User", :double_checked).content
    end

    it "is added to user's +double_checked card" do
      expect(double_checked).to include("[[~#{metric_answer_card.id}]]")
    end

    context "value updated" do
      before do
        metric_value_card.value_card.update_attributes content: "200"
      end
      it "clears double checked status" do
        expect(checked_by.content).to eq ""
      end
    end

  end

  describe "uncheck value" do
    it "checks the metric value" do
      Card::Env.params["set_flag"] = "not-checked"
      cb_card = metric_answer_card.fetch trait: :checked_by,
                                        new: { content: "[[Joe User]]" }
      cb_card.save!
      cb_card.update_attributes! subcards: {}
      expect(cb_card.item_names.size).to eq(0)
    end
  end
end
