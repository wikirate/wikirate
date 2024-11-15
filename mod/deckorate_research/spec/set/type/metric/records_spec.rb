# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Metric::Records do
  context "when renaming metric" do
    it "renames records in lookup table", as_bot: true do
      # update_card "Joe User+researched number 1",
      #             name: "Joe User+invented number"
      Card["Joe User+researched number 1"]
        .update! name: "Joe User+invented number"

      record = Card["Joe User+invented number"].records.first
      expect(record.metric.title_id.cardname).to eq "invented number"
    end
  end
end
