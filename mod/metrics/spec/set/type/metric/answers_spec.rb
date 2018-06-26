# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Metric::Answers do
  context "when renaming metric" do
    it "renames answers in lookup table", as_bot: true do
      # update_card "Joe User+researched number 1",
      #             name: "Joe User+invented number", update_referers: true
      Card["Joe User+researched number 1"]
        .update_attributes! name: "Joe User+invented number", update_referers: true

      answer = Card["Joe User+invented number"].all_answers.first
      expect(answer.title_name).to eq "invented number"
    end
  end
end
