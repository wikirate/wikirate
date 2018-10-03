# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::MetricAnswer, "hybrid" do
  let(:metric) { Card["Jedi+friendliness"] }
  let(:company) { "Death Star" }
  let(:input_metric) { Card["Jedi+deadliness"] }
  let(:calculated_answer) { answer 1977 }

  def answer year=1977
    Card.fetch(metric.name, company,  year.to_s)
  end

  def research_value value, year=1977
    metric.create_values true do
      Death_Star year.to_s => value.to_s
    end
  end

  def input_for_calculation value, year=2010
    input_metric.create_values true do
      Death_Star year.to_s => value.to_s
    end
  end

  def delete_input year=2010
    Card::Auth.as_bot do
      Card[input_metric, company, year.to_s].delete!
    end
  end

  example "research calculated value" do
    expect(answer.overridden_value).to eq ""
    research_value 5
    expect(answer.overridden_value).to eq "0.01"
    expect(answer.value).to eq "5"
    expect(answer).to be_calculation_overridden
  end

  example "calculate researched value" do
    research_value 5, 2010
    expect(answer(2010).answer.answer_id).to be_present
    input_for_calculation 10, 2010
    expect(answer(2010).value).to eq "5"
    expect(answer(2010).overridden_value).to eq "0.1"
    expect(answer(2010).answer.answer_id).to be_present
    expect(answer(2010)).to be_calculation_overridden
  end

  example "uncalculate researched value" do
    research_value 5
    expect(answer.overridden_value).to eq "0.01"
    delete_input 1977
    expect(answer.value).to eq "5"
    expect(answer.overridden_value).to eq ""
    expect(answer.calculation_overridden?).to be_falsey
  end

  example "unresearch calculated value", as_bot: true do
    expect(calculated_answer.overridden_value).to eq ""
    research_value 5
    expect(answer.value).to eq "5"
    Card[metric, company, "1977"].delete!
    expect(calculated_answer.overridden_value).to eq ""
    expect(calculated_answer.value).to eq "0.01"
    expect(calculated_answer).not_to be_calculation_overridden
  end
end
