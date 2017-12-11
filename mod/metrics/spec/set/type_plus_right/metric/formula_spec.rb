# encoding: UTF-8

describe Card::Set::TypePlusRight::Metric::Formula do
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

  it "calculates values if metric is created with formula" do
    Card::Metric.create name: "Jedi+formula test",
                        type: :formula,
                        formula: "{{Jedi+deadliness}}/{{Jedi+Victims by Employees}}"

    answer_card = Card["Jedi+formula test+Death Star+1977+value"]
    expect(answer_card).to be_instance_of Card
    expect(answer_card.content).to match(/^322/)
    answer = Answer.where(answer_id: answer_card.left_id)
    expect(answer).to be_present
    expect(answer.first.value).to match(/^322/)
  end

  it "calculates values if formula is added" do
    Card::Metric.create name: "Jedi+formula test",
                        type: :formula

    create "Jedi+formula test+formula", content: "{{Jedi+deadliness}}/{{Jedi+Victims by Employees}}"
    answer_card = Card["Jedi+formula test+Death Star+1977+value"]
    expect(answer_card).to be_instance_of Card
    expect(answer_card.content).to match(/^322/)
    answer = Answer.where(answer_id: answer_card.left_id)
        expect(answer).to be_present
        expect(answer.first.value).to match(/^322/)
  end
end
