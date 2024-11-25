RSpec.describe Card::Set::Type::Answer do
  describe "#each_reference_dump_row" do
    let :yielded_answers do
      [].tap { |rows| card_subject.each_reference_dump_row { |row| rows << row } }
    end

    context "when answer is researched" do
      def card_subject
        "Jedi+disturbances_in_the_Force+Death_Star+2001".card
      end

      it "finds only self" do
        expect(yielded_answers).to eq [card_subject.answer]
      end
    end

    context "when answer is calculated" do
      def card_subject
        Card.fetch "Jedi+darkness rating+Death Star+1977"
      end

      it "finds self and all dependee_answers" do
        ya = yielded_answers
        expect(ya.size).to eq 5
        expect(ya.first).to eq card_subject.answer
      end
    end
  end
end
