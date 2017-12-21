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

    answer = Answer.where(record_name: "Jedi+formula test+Death Star", year: 1977).take
    expect(answer).to be_present
    expect(answer.value).to match(/^322/)
  end

  it "calculates values if formula is added" do
    Card::Metric.create name: "Jedi+formula test",
                        type: :formula

    create "Jedi+formula test+formula",
           content: "{{Jedi+deadliness}}/{{Jedi+Victims by Employees}}"

    answer = Answer.where(record_name: "Jedi+formula test+Death Star", year: 1977).take
    expect(answer).to be_present
    expect(answer.value).to match(/^31.0/)
  end

  it "calculates values if formula changed" do
    Card::Metric.create name: "Jedi+formula test",
                        type: :formula,
                        formula: "{{Jedi+deadliness}}/{{Jedi+Victims by Employees}}"
    Card["Jedi+formula test+formula"].update_attributes!(
      content: "{{Jedi+deadliness}}*{{Jedi+Victims by Employees}}"
    )

    answer = Answer.where(record_name: "Jedi+formula test+Death Star", year: 1977).take
    expect(answer).to be_present
    expect(answer.value).to match(/^0.08/)
  end

  def fetch_answer_value metric_title
    where_args = { record_name: "Jedi+#{metric_title}+Death Star", year: 1977 }
    Answer.where(where_args).take.value
  end

  example "formula with formula input" do
    Card::Metric.create name: "Jedi+double friendliness",
                        type: :formula,
                        formula: "{{Jedi+friendliness}}*2"
    value = fetch_answer_value "double friendliness"
    expect(value).to match /0.02/
  end

  context "when researched input changed" do
    it "updates calculated values if researched input changed" do
      value = fetch_answer_value "friendliness"
      expect(value).to match /0.01/
      update_card "Jedi+deadliness+Death Star+1977+value", content: "10"
      expect(value).to match /0.1/
    end

    it "updates second level formula" do
      Card::Metric.create name: "Jedi+double friendliness",
                          type: :formula,
                          formula: "{{Jedi+friendliness}}*2"
      value = fetch_answer_value "double friendliness"
      expect(value).to match /0.02/
      update_card "Jedi+deadliness+Death Star+1977+value", content: "10"
      value = fetch_answer_value "double friendliness"
      expect(value).to match /0.2/
    end
  end
end
