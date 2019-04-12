# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::TypePlusRight::Metric::ValueOptions do
  it "doesn't contextualize item names" do
    card = Card.new name: "options+value options", content: "[[A+]]\n[[+B]]"
    expect(card.item_names).to contain_exactly "A+", "+B"
  end
end
