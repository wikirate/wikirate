require_relative "samples"

class SharedData
  # test data for metrics
  module CalculatedMetrics
    include Samples

    def add_calculated_metrics
      Card::Env[:protocol] = "http://"
      Card::Env[:host] = "wikirate.org"
      formula_metrics
      score_metrics
      wikirating_metrics
      descendant_metrics
    end

    def formula_metrics
      Card::Metric.create name: "Jedi+friendliness",
                          type: :formula,
                          formula: "1/{{Jedi+deadliness}}",
                          hybrid: "1",
                          test_source: true do
        Slate_Rock_and_Gravel_Company 2003 => "100"
      end

      Card::Metric.create name: "Jedi+double friendliness",
                          type: :formula,
                          formula: "{{Jedi+friendliness}}*2"

      Card::Metric.create name: "Jedi+deadliness average",
                          type: :formula,
                          formula: "Total[{{Jedi+deadliness|year:-2..0}}]/3"
      Card::Metric.create name: "Jedi+deadlier",
                          type: :formula,
                          hybrid: "1",
                          formula: "{{Jedi+deadliness}}-{{Jedi+deadliness|year:-1}}" \
                                   "+{{half year}}"

      # calculated value: "Slate Rock and Gravel Company+2004"


    end

    def score_metrics
      Card::Metric.create name: "Jedi+deadliness+Joe User",
                          type: :score,
                          formula: "{{Jedi+deadliness}}/10"
      Card::Metric.create name: "Jedi+deadliness+Joe Camel",
                          type: :score,
                          formula: "{{Jedi+deadliness}}/20"

      with_joe_user do
        Card::Metric.create name: "Jedi+disturbances in the Force+Joe User",
                            type: :score,
                            formula: { yes: 10, no: 0 }
      end
    end

    def wikirating_metrics
      Card::Metric.create(
        name: "Jedi+darkness rating",
        type: :wiki_rating,
        formula: { "Jedi+deadliness+Joe User" => 60,
                   "Jedi+disturbances in the Force+Joe User" => 40 }
      )
    end

    def descendant_metrics
      Card::Metric.create(
        name: "Joe User+descendant 1",
        type: :descendant,
        formula: "[[Joe User+researched number 2]]\n" \
                 "[[Joe User+researched number 1]]"
      )

      Card::Metric.create name: "Joe User+descendant hybrid",
                          type: :descendant,
                          formula: "[[Joe User+researched number 2]]\n" \
                                   "[[Joe User+researched number 1]]",
                          hybrid: "1",
                          test_source: true do
        Death_Star 1977 => 1000
      end

      Card::Metric.create(name: "Joe User+descendant 2",
                          type: :descendant,
                          formula: "[[Joe User+RM]]\n" \
                                   "[[Joe User+researched number 1]]"
                         )
    end
  end
end
