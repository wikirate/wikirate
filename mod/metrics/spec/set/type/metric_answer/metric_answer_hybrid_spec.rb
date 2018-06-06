# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::MetricAnswer, "hybrid" do
  let(:metric) { Card["Jedi+deadlier"] }
  let(:calculated_answer) do
    Card.fetch(metric.name, "Slate Rock and Gravel Company", "2004")
  end

  context "when calculated value overriden" do
    example do
      metric.create_values true do
        Slate_Rock_and_Gravel_Company "2004" => "5"
      end
      expect(calculated_answer.calculatedvalue).to eq "5"
    end
  end
end
