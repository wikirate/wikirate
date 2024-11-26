RSpec.describe Card::Set::Type::Dataset do
  describe "#each_reference_dump_row" do
    let :yielded_answers do
      [].tap { |rows| card_subject.each_reference_dump_row { |row| rows << row } }
    end

    context "when metric is researched" do
      def card_subject
        "Evil Dataset".card
      end

      it "finds all cards in dataset" do
        expect(yielded_answers.size)
          .to eq(card_subject.fetch(:answer).count)
      end
    end
  end
end
