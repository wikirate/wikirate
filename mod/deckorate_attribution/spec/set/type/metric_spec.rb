RSpec.describe Card::Set::Type::Metric do
  describe "#each_reference_dump_row" do
    let :yielded_answers do
      [].tap { |rows| card_subject.each_reference_dump_row { |row| rows << row } }
    end

    context "when metric is researched" do
      def card_subject
        "Jedi+disturbances_in_the_Force".card
      end

      it "finds direct answers to metric" do
        expect(yielded_answers.size)
          .to be(::Answer.where(metric_id: card_subject.id).count)
      end
    end

    context "when metric is calculated" do
      def card_subject
        Card.fetch "Jedi+darkness rating"
      end

      it "finds all dependee_answers" do
        ya = yielded_answers
        expect(ya.size).to eq 15
        expect(ya.first.metric_id).to eq card_subject.id
        expect(ya.last.metric_id).not_to eq card_subject.id
      end
    end
  end
end
