# encoding: UTF-8

RSpec.describe Card::Set::TypePlusRight::Metric::Formula::Calculations do
  def calc_answer metric_title="formula test"
    Answer.where(metric_name: "Jedi+#{metric_title}",
                 company_id: Card.fetch_id("Death Star"),
                 year: 1977).take
  end

  def answer_value metric_title="formula test"
    calc_answer(metric_title).value
  end

  # values for the input answers are 100 and 0.31
  def create_formula formula: "{{Jedi+deadliness}}/{{Jedi+Victims by Employees}}",
                     title: "formula test"
    Card::Metric.create name: "Jedi+#{title}", type: :formula, formula: formula
  end

  def updates_answer_with_delay from: nil, to:, metric_title: "formula test"
    with_delayed_jobs do
      expect(answer_value(metric_title)).to match(from) if from
      yield
      expect(answer_value(metric_title)).to match(from) if from
      expect(calc_answer(metric_title).calculating)
        .to be_truthy,
            "'Jedi+#{metric_title}+Death Star+1977' not marked as being calculated"
    end
    expect(answer_value(metric_title)).to match(to)
    expect(calc_answer(metric_title).calculating).to be_falsey
  end

  context "when formula is updated" do
    it "updates values" do
      with_delayed_jobs { create_formula }
      expect(answer_value).to match(/^322/)

      updates_answer_with_delay to: /^31/ do
        Card["Jedi+formula test+formula"].update_attributes!(
          content: "{{Jedi+deadliness}}*{{Jedi+Victims by Employees}}"
        )
      end
    end

    it "updates values of dependent calculated metric" do
      with_delayed_jobs { create_formula } # create Jedi+formula test
      with_delayed_jobs do
        create_formula title: "formula test double",
                       formula: "{{Jedi+formula test}}*2"
      end

      updates_answer_with_delay from: /^645/, to: /^62/,
                                metric_title: "formula test double" do
        Card["Jedi+formula test+formula"].update_attributes!(
          content: "{{Jedi+deadliness}}*{{Jedi+Victims by Employees}}"
          )
      end
    end
  end

  context "when formula is created" do
    it "creates dummy answers" do
      updates_answer_with_delay to: /^322/ do
        create_formula
        expect(calc_answer.calculating).to be_truthy
        answer_card = Card.fetch("Jedi+formula test+Death Star+1977", type: :metric_answer)
        expect(answer_card.answer.id).to eq calc_answer.id
        expect(view(:core, card: "Jedi+formula test+all metric values")).to have_tag :tr do
          with_text /Death Star/
          with_tag "i.fa-refresh"
        end
      end
    end
  end

  it "calculates values if formula is added" do
    updates_answer_with_delay to: /^322/ do
      Card::Metric.create name: "Jedi+formula test", type: :formula
      create "Jedi+formula test+formula",
             content: "{{Jedi+deadliness}}/{{Jedi+Victims by Employees}}"
    end
  end

  example "formula with formula input" do
    create_formula title: "triple friendliness",
                   formula: "{{Jedi+friendliness}}*3"

    expect(answer_value("triple friendliness")).to match /0.03/
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
