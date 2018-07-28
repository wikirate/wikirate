# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Metric::Events do
  describe "#update_lookup_answers" do
    context "when renaming calculated metrics" do
      let(:oldname) { "Jedi+friendliness" }
      let(:newname) { "Jedi+flakiness" }
      let(:newcard) { Card[newname] }

      before { Card[oldname].update_attributes! name: newname, update_referers: true }

      it "updates metric names in lookup table", as_bot: true do
        expect(newcard.all_answers.first.metric_name).to eq(newname)
      end

      it "doesn't add or lose answers" do
        expect(newcard.all_answers.size).to eq(8)
      end
    end
  end

  describe "#delete answers" do
    let(:metric) { Card["Joe User+researched number 1"] }
    let(:delete_metric) { metric.update_attributes trigger: :delete_answers }

    it "fails without admin permission" do
      delete_metric
      expect(metric.errors).to have_key(:answers)
    end

    it "deletes all of a metric's answers" do
      Card::Auth.as_bot do
        delete_metric
        expect(metric.all_answers.size).to eq(0)
      end
    end
  end
end
