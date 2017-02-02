describe Card::Set::TypePlusRight::MetricValue::CheckedBy do
  let(:answer_card) { Card["joe_user+researched+death_star+1977"] }

  describe "check value" do
    before do
      Card::Env.params["set_flag"] = "checked"
      cb_card.save!
      cb_card.update_attributes! subcards: {}
      Card::Env.params.delete "set_flag"
    end
    let(:cb_card) do
      answer_card.fetch trait: :checked_by, new: {}
    end

    it "checks the metric value" do
      expect(cb_card.item_names.size).to eq(1)
      expect(cb_card.item_names).to include("Joe User")
    end

    let(:checked_by) do
      answer_card.fetch trait: :checked_by
    end
    let(:double_checked) do
      Card.fetch("Joe User", :double_checked).content
    end

    it "is added to user's +double_checked card" do
      expect(double_checked).to include("[[~#{answer_card.id}]]")
    end

    context "value updated" do
      before do
        answer_card.value_card.update_attributes content: "200"
      end
      it "clears double checked status" do
        expect(checked_by.content).to eq ""
      end
    end
  end

  describe "uncheck value" do
    it "checks the metric value" do
      Card::Env.params["set_flag"] = "not-checked"
      cb_card = answer_card.fetch trait: :checked_by,
                                  new: { content: "[[Joe User]]" }
      cb_card.save!
      cb_card.update_attributes! subcards: {}
      expect(cb_card.item_names.size).to eq(0)
    end
  end
end
