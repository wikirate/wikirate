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

  def answer_value metric_title
    where_args = { metric_name: "Jedi+#{metric_title}",
                   company_id: Card.fetch_id("Death Star"), year: 1977 }
    Answer.where(where_args).take.value
  end

  it "calculates values if metric is created with formula" do
    Card::Metric.create name: "Jedi+formula test",
                        type: :formula,
                        formula: "{{Jedi+deadliness}}/{{Jedi+Victims by Employees}}"

    expect(answer_value("formula test")).to match(/^322/)
  end

  it "calculates values if formula is added" do
    Card::Metric.create name: "Jedi+formula test",
                        type: :formula

    create "Jedi+formula test+formula",
           content: "{{Jedi+deadliness}}/{{Jedi+Victims by Employees}}"

    expect(answer_value("formula test")).to match(/^322/)
  end

  context "when formula changed" do
    it "updates values" do
      Card::Metric.create name: "Jedi+formula test",
                          type: :formula,
                          formula: "{{Jedi+deadliness}}/{{Jedi+Victims by Employees}}"
      expect(answer_value("formula test")).to match(/^322/)
      Card["Jedi+formula test+formula"].update_attributes!(
        content: "{{Jedi+deadliness}}*{{Jedi+Victims by Employees}}"
      )
      expect(answer_value("formula test")).to match(/^31/)
    end

    it "updates values of dependent calculated metric" do
      Card::Metric.create name: "Jedi+formula test",
                          type: :formula,
                          formula: "{{Jedi+deadliness}}/{{Jedi+Victims by Employees}}"

      Card::Metric.create name: "Jedi+formula test double",
                          type: :formula,
                          formula: "{{Jedi+formula test}}*2"
      expect(answer_value("formula test")).to match(/^322/)

      Card["Jedi+formula test+formula"].update_attributes!(
        content: "{{Jedi+deadliness}}*{{Jedi+Victims by Employees}}"
      )

      expect(answer_value("formula test double")).to match(/^645/)
    end
  end

  example "formula with formula input" do
    Card::Metric.create name: "Jedi+double friendliness",
                        type: :formula,
                        formula: "{{Jedi+friendliness}}*2"
    value = answer_value "double friendliness"
    expect(value).to match /0.02/
  end

  context "when researched input changed" do
    it "updates calculated values if researched input changed" do
      expect(answer_value("friendliness")).to eq "0.01"
      update_card "Jedi+deadliness+Death Star+1977+value", content: "10"
      researched_value = answer_value "deadliness"
      expect(researched_value).to eq "10"
      overridden_value = answer_value "friendliness"
      expect(overridden_value).to eq "0.1"
    end

    it "updates second level formula" do
      Card::Metric.create name: "Jedi+double friendliness",
                          type: :formula,
                          formula: "{{Jedi+friendliness}}*2"
      expect(answer_value("double friendliness")).to eq "0.02"
      update_card "Jedi+deadliness+Death Star+1977+value", content: "10"
      expect(answer_value("double friendliness")).to eq "0.2"
    end
  end
end
