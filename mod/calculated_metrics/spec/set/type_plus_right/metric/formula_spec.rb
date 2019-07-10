# encoding: UTF-8

RSpec.describe Card::Set::TypePlusRight::Metric::Formula do
  describe "#ruby_formula?" do
    def formula content
      Card["Jedi+friendliness+formula"].tap do |card|
        card.content = content
      end
    end

    it "allows math operations" do
      expect(formula("5 * 4 / 2 - 2.3 + 5")).to be_ruby_formula
    end

    it "allows parens" do
      expect(formula("5 * (4 / 2) - 2")).to be_ruby_formula
    end

    it "allows nests" do
      expect(formula("5 * {{metric}} + 5")).to be_ruby_formula
    end

    it "denies letters" do
      expect(formula("5 * 4*a / 2")).not_to be_ruby_formula
    end
  end

  it "show input options in thumbnail" do
    expect_view(:core, card: "Jedi+deadliness average+formula")
      .to have_tag "div.thumbnail", with: { "data-card-name": "Jedi+deadliness" } do
        with_tag "div.thumbnail-subtitle", "Research | community assessed | year: -2..0"
    end
  end
end
