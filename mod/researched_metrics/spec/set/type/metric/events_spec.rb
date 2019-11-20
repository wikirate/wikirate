# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Metric::Events do
  describe "#update_lookup_answers" do
    context "when renaming calculated metrics", as_bot: true do
      let(:oldname) { "Jedi+friendliness" }
      let(:newname) { "Joe User+flakiness" }
      let(:newcard) { Card[newname] }

      before { Card[oldname].update! name: newname, update_referers: true }

      it "updates metric names in lookup table" do
        expect(newcard.all_answers.first.metric_name).to eq(newname)
      end

      it "updates metric titles in lookup table" do
        expect(newcard.all_answers.first.title_name).to eq(newname.to_name.right)
      end

      it "updates metric designer in lookup table" do
        expect(newcard.all_answers.first.designer_name).to eq(newname.to_name.left)
      end

      it "updates record names in lookup table" do
        expect(newcard.all_answers.first.record_name)
          .to match(Regexp.new(Regexp.quote(newname)))
      end

      it "doesn't add or lose answers" do
        expect(newcard.all_answers.size).to eq(8)
      end
    end
  end
end
