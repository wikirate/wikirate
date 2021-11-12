require_relative "samples"

class SharedData
  # test data for metrics
  module CalculatedMetrics
    include Samples

    def add_calculated_metrics
      Card::Env[:protocol] = "http://"
      Card::Env[:host] = "wikirate.org"
      formula_metrics
      descendant_metrics
    end

    def formula_metrics
      Card::Metric::AnswerCreator.new "Jedi+friendliness", true do
        Slate_Rock_and_Gravel_Company 2003 => "100"
      end.add_answers
    end

    def descendant_metrics
      Card::Metric::AnswerCreator.new "Joe User+descendant hybrid", true do
        Death_Star 1977 => 1000
      end.add_answers
    end
  end
end
