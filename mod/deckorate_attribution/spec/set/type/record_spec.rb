RSpec.describe Card::Set::Type::Record do
  describe "#each_reference_dump_row" do
    let :yielded_records do
      [].tap { |rows| card_subject.each_reference_dump_row { |row| rows << row } }
    end

    context "when record is researched" do
      def card_subject
        "Jedi+disturbances_in_the_Force+Death_Star+2001".card
      end

      it "finds only self" do
        expect(yielded_records).to eq [card_subject.record]
      end
    end

    context "when record is calculated" do
      def card_subject
        Card.fetch "Jedi+darkness rating+Death Star+1977"
      end

      it "finds self and all dependee_records" do
        ya = yielded_records
        expect(ya.size).to eq 5
        expect(ya.first).to eq card_subject.record
      end
    end
  end
end
