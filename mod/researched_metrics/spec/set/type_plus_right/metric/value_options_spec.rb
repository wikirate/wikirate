# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::TypePlusRight::Metric::ValueOptions do
  it "doesn't contextualize item names" do
    card = Card.new name: "Joe User+RM+value options", content: "[[A+]]\n[[+B]]"
    expect(card.item_names).to contain_exactly "A+", "+B"
  end

  it "doesn't allow removal of options with answers" do
    options_card = Card["Fred+dinosaurlabor+value options"]
    options_card.update content: "[[yes]]\n[[maybe]]"
    expect(options_card).to be_invalid.because_of answers: include("valid options")
  end
end
