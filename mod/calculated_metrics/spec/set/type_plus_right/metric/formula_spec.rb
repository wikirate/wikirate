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

  context "when formula is updated" do
    it "marks values as beeing calculated" do

    end

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

    it "updates values of other dependent calculated metrics" do

    end

  end

  context "when formula is created" do
    it "calculates values" do
        Card::Metric.create name: "Jedi+formula test",
                            type: :formula,
                            formula: "{{Jedi+deadliness}}/{{Jedi+Victims by Employees}}"

        expect(answer_value("formula test")).to match(/^322/)
      end
  end


  it "calculates values if formula is added" do
    Card::Metric.create name: "Jedi+formula test",
                        type: :formula

    create "Jedi+formula test+formula",
           content: "{{Jedi+deadliness}}/{{Jedi+Victims by Employees}}"

    expect(answer_value("formula test")).to match(/^322/)
  end

  example "formula with formula input" do
    Card::Metric.create name: "Jedi+triple friendliness",
                        type: :formula,
                        formula: "{{Jedi+friendliness}}*3"
    value = answer_value "triple friendliness"
    expect(value).to match /0.03/
  end

  context "when researched input changed" do
    def change_research_input
      update_card "Jedi+deadliness+Death Star+1977+value", content: "10"
      researched_value = answer_value "deadliness"
      expect(researched_value).to eq "10"
    end

    it "updates calculated values" do
      expect { change_research_input }
        .to change { answer_value "friendliness" }
        .from("0.01").to("0.1")
    end

    it "updates second level formula" do
      expect { change_research_input }
        .to change { answer_value("double friendliness") }
        .from("0.02").to("0.2")
    end
  end
end
