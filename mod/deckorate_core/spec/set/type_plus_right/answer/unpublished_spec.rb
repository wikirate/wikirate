RSpec.describe Card::Set::TypePlusRight::Answer::Unpublished do
  let(:researched_answer) { Card["Jedi+deadliness+Death_Star+1977"] }
  let(:wikirating_answer) { Card.fetch "Jedi+darkness_rating+Death_Star+1977" }

  before do
    researched_answer.unpublished_card.update! content: 1
  end

  it "updates answer lookup table on create" do
    expect(researched_answer.answer.unpublished).to be_truthy
  end

  it "updates answer lookup table on delete", as_bot: true do
    answer = researched_answer.refresh true
    answer.unpublished_card.delete!
    expect(answer.answer.unpublished).to be_falsey
  end

  it "'unpublishes' calculated answer when researched answer is unpublished" do
    expect(wikirating_answer.answer.unpublished).to be_truthy # unpublished
    expect(wikirating_answer.answer).to be_unpublished        # unpublished?
  end

  it "'publishes' calculated answer when researched answer is published", as_bot: true do
    researched_answer.unpublished_card.update! content: 0
    expect(wikirating_answer.answer.unpublished).to be_falsey
  end
end
