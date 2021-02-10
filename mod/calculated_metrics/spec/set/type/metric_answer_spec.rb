RSpec.describe Card::Set::Type::MetricAnswer do
  context "with WikiRating" do
    let(:answer) { Card.fetch "Jedi+darkness_rating+Death_Star+1977" }

    example "#direct_dependee_answers" do
      expect(answer.direct_dependee_answers.count).to eq(2)
    end

    example "#dependee_answers" do
      expect(answer.dependee_answers.count).to eq(4)
    end

    example "#calculated_verification" do
      expect(answer.calculated_verification).to eq(1)
    end
  end
end
