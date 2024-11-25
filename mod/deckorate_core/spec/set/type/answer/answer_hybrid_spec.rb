# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Answer, "hybrid" do
  let(:metric) { Card["Jedi+friendliness"] }
  let(:company) { "Death Star" }
  let(:input_metric) { Card["Jedi+deadliness"] }
  let(:calculated_answer) { answer 1977 }

  def answer year=1977
    Card.fetch(metric.name, company, year.to_s).answer
  end

  def research_value value, year=1977
    create_answers metric, true do
      Death_Star year.to_s => value.to_s
    end
  end

  def input_for_calculation value, year=2010
    create_answers input_metric, true do
      Death_Star year.to_s => value.to_s
    end
  end

  def delete_input year=2010
    Card::Auth.as_bot do
      Card[input_metric, company, year.to_s].delete!
    end
  end

  example "initial value" do
    expect(answer.overridden_value).to eq nil
    expect(answer.value).to eq "0.01"
  end

  example "research calculated value" do
    research_value 5
    expect(answer).to have_attributes(overridden_value: "0.01",
                                      value: "5",
                                      answer_id: a_kind_of(Integer))
  end

  example "calculate researched value 1" do
    research_value 5, 2010
    input_for_calculation 10, 2010
    expect(answer(2010)).to have_attributes(value: "5",
                                            overridden_value: "0.1",
                                            answer_id: a_kind_of(Integer))
  end

  example "uncalculate researched value" do
    research_value 5
    delete_input 1977
    expect(answer).to have_attributes(value: "5",
                                      overridden_value: nil,
                                      answer_id: a_kind_of(Integer))
  end

  example "unresearch calculated value", as_bot: true do
    research_value 5
    Card[metric, company, "1977"].delete!
    expect(answer).to have_attributes(overridden_value: nil,
                                      answer_id: nil,
                                      value: "0.01")
  end
end
