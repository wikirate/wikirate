RSpec.describe Card::Set::Right::CheckedBy::Events do
  let(:flagged_record) { ["Fred", "dinosaurlabor", "Death Star", "2010"].card }

  describe "#close_flags" do
    it "closes all open flags for record" do
      expect(flagged_record.record.open_flags).to eq(1)
      flagged_record.checked_by_card.close_flags
      expect(flagged_record.record.open_flags).to eq(0)
    end
  end

  describe "event: add_check" do
    it "adds user name and closes flags" do
      flagged_record.checked_by_card.update! trigger: :add_check
      expect(flagged_record.checked_by).to eq("Joe User")
      expect(flagged_record.record.open_flags).to eq(0)
    end
  end
end
