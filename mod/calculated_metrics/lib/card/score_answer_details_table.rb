class Card
  # Renders the table with details for an answer of a score metric
  class ScoreAnswerDetailsTable < AbstractAnswerDetailsTable
    @columns = ["Original Metric", "Value"]

    def table_rows
      [metric_row(base_metric_card)]
    end

    def value
      @format.wrap_with(:span, base_metric_answer.value, class: "metric-value")
    end

    def base_metric_card
      @format.card.metric_card.left
    end

    def base_metric_answer
      base_metric_card.field(company).field(year)
    end
  end
end
