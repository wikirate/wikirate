RSpec.describe Card::Set::TypePlusRight::MetricAnswer::Unpublished do
  before do
    sample_answer.unpublished_card.update! content: 1
  end
  it "updates answer lookup table on create" do
    expect(sample_answer.answer.unpublished).to be_truthy
  end

  it "updates answer lookup table on delete", as_bot: true do
    sample_answer.unpublished_card.delete!
    expect(sample_answer.answer.unpublished).to be_falsey
  end
end
