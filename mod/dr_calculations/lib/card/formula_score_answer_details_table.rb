# TODO: add formula!

class Card
  # Renders the table with details for an answer of a score metric
  class FormulaScoreAnswerDetailsTable < AbstractAnswerDetailsTable
    @columns = ["Scored Metric", "Value"]

    def table_rows
      [metric_row(base_metric_card)]
    end

    def link_to_answer _answer_card
      super base_metric_answer
    end
  end
end
