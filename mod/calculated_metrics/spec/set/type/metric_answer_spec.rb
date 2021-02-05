RSpec.describe Card::Set::Type::MetricAnswer do
  describe "#dependee_answers" do
    let(:answer) { Card.fetch "Jedi+darkness_rating+Death_Star+1977" }

    example "WikiRating" do
      expect(answer.dependee_answers.count).to eq(2)
    end

  end
end
