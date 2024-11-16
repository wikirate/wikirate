RSpec.describe Card::Set::MetricType::InverseRelation do
  def card_subject
    Card["Jedi+less evil"]
  end

  describe "value_type" do
    it "is the same as inverse" do
      expect(card_subject.value_type).to eq(card_subject.inverse_card.value_type)
    end
  end
end
