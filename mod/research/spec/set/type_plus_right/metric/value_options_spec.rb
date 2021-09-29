# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::TypePlusRight::Metric::ValueOptions do
  def update_options metric, options
    options_card = Card[metric, :value_options]
    options_card.update content: options
    options_card
  end

  it "doesn't contextualize item names" do
    card = Card.new name: "Joe User+RM+value options", content: "[[A+]]\n[[+B]]"
    expect(card.item_names).to contain_exactly "A+", "+B"
  end

  it "doesn't allow removal of options with answers" do
    options_card = update_options "Fred+dinosaurlabor", "[[yes]]\n[[maybe]]"
    expect(options_card).to be_invalid.because_of content: include("answers invalid")
  end

  it "doesn't allow commas in multi-category options" do
    options_card = update_options "Joe User+small multi", "[[A, B]]"
    expect(options_card).to be_invalid.because_of content: include("cannot have commas")
  end

  context "with JSON options" do
    def card_subject
      Card.new name: "Joe User+RM+value options",
               type: :json,
               content: '{"2 As":"aa", "2 Bs":"bb"}'
    end

    it "renders items on separate lines in core view" do
      expect_view(:core).to have_tag(".pointer-item", "2 As")
    end
  end
end
