# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Metric::Events do
  describe "#update_lookup_answers" do
    context "when renaming calculated metrics", as_bot: true do
      let(:oldname) { "Jedi+friendliness" }
      let(:newname) { "Joe User+flakiness".to_name }
      let(:newcard) { Card[newname] }

      before do
        Card[oldname].update! name: newname
      end

      it "updates metric names in lookup table" do
        expect(newcard.answers.first.metric_name).to eq(newname)
      end

      it "updates metric title ids in lookup table" do
        expect(newcard.lookup.title_id.cardname).to eq(newname.right)
      end

      it "updates metric designer in lookup table" do
        expect(newcard.lookup.designer_id.cardname).to eq(newname.left)
      end

      it "translates record_id in lookup table to current record name" do
        expect(newcard.answers.first.record_name)
          .to match(Regexp.new(Regexp.quote(newname)))
      end

      it "doesn't add or lose answers" do
        expect(newcard.answers.size).to eq(8)
      end
    end
  end
end
