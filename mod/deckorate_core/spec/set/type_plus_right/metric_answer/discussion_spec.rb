RSpec.describe Card::Set::TypePlusRight::MetricAnswer::Discussion do
  it "updates lookup" do
    answer_card = sample_answer
    answer_card.discussion_card.update! content: "nice weather, eh?"
    expect(answer_card.answer.comments).to match(/weather/)
  end
end
