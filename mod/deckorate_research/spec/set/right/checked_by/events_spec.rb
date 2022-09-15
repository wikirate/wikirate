RSpec.describe Card::Set::Right::CheckedBy::Views do
  let(:flagged_answer) { ["Fred", "dinosaurlabor", "Death Star", "2010"].card }

  describe "#close_flags" do
    it "closes all open flags for answer" do
      expect(flagged_answer.answer.open_flags).to eq(1)
      flagged_answer.checked_by_card.close_flags
      expect(flagged_answer.answer.open_flags).to eq(0)
    end
  end

  describe "event: add_check" do
    it "adds user name and closes flags" do
      flagged_answer.checked_by_card.update! trigger: :add_check
      expect(flagged_answer.checked_by).to eq("Joe User")
      expect(flagged_answer.answer.open_flags).to eq(0)
    end
  end
end
