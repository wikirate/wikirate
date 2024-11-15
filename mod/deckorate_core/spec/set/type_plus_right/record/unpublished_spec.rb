RSpec.describe Card::Set::TypePlusRight::Record::Unpublished do
  let(:researched_record) { Card["Jedi+deadliness+Death_Star+1977"] }
  let(:wikirating_record) { Card.fetch "Jedi+darkness_rating+Death_Star+1977" }

  before do
    researched_record.unpublished_card.update! content: 1
  end

  it "updates record lookup table on create" do
    expect(researched_record.record.unpublished).to be_truthy
  end

  it "updates record lookup table on delete", as_bot: true do
    record = researched_record.refresh true
    record.unpublished_card.delete!
    expect(record.record.unpublished).to be_falsey
  end

  it "'unpublishes' calculated record when researched record is unpublished" do
    expect(wikirating_record.record.unpublished).to be_truthy # unpublished
    expect(wikirating_record.record).to be_unpublished        # unpublished?
  end

  it "'publishes' calculated record when researched record is published", as_bot: true do
    researched_record.unpublished_card.update! content: 0
    expect(wikirating_record.record.unpublished).to be_falsey
  end
end
