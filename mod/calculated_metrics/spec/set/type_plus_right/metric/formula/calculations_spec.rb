# encoding: UTF-8

RSpec.describe Card::Set::TypePlusRight::Metric::Formula::Calculations do
  def answer metric_title
    Answer.where(metric_name: "Jedi+#{metric_title}",
                 company_id: Card.fetch_id("Death Star"),
                 year: 1977).take
  end

  def answer_value metric_title
    answer(metric_title).value
  end

  def create_formula formula: "{{Jedi+deadliness}}/{{Jedi+Victims by Employees}}",
                     name: "Jedi+formula test"
    Card::Metric.create name: name, type: :formula, formula: formula
  end

  context "when formula is updated" do
    it "updates values" do
      create_formula
      expect(answer_value("formula test")).to match(/^322/)
      Card["Jedi+formula test+formula"].update_attributes!(
        content: "{{Jedi+deadliness}}*{{Jedi+Victims by Employees}}"
      )
      expect(answer_value("formula test")).to match(/^31/)
    end

    it "updates values of dependent calculated metric" do
      create_formula
      create_formula name: "Jedi+formula test double",
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

    it "creates dummy answers" do
      with_delayed_jobs do
        Card::Metric.create name: "Jedi+formula test",
                            type: :formula,
                            formula: "{{Jedi+deadliness}}/{{Jedi+Victims by Employees}}"
        expect_view(:core, card: "Jedi+formula test").to include "Death Star"
      end
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
      expect(answer_value("friendliness")).to eq "0.01"
      change_research_input
      overridden_value = answer_value "friendliness"
      expect(overridden_value).to eq "0.1"
    end

    it "updates second level formula" do

      expect(answer_value("double friendliness")).to eq "0.02"
      change_research_input
      expect(answer_value("double friendliness")).to eq "0.2"
    end
  end
end