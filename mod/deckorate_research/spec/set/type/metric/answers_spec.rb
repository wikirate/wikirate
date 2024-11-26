# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Metric::Answers do
  context "when renaming metric" do
    it "renames answers in lookup table", as_bot: true do
      # update_card "Joe User+researched number 1",
      #             name: "Joe User+invented number"
      Card["Joe User+researched number 1"]
        .update! name: "Joe User+invented number"

      answer = Card["Joe User+invented number"].answers.first
      expect(answer.metric.title_id.cardname).to eq "invented number"
    end
  end
end
