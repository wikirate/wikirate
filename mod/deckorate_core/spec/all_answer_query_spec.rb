RSpec.describe Card::AllAnswerQuery do
  describe "#updated_by_query" do
    it "finds records updated by single user" do
      # puts described_class.new(updater: "Joe_User").main_query.to_sql
      expect(described_class.new(updater: "Joe_User").main_query.count).to eq(8)
    end
  end
end