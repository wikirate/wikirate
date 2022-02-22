class Card
  # Renders the table with details for an answer of a Descendant metric
  class DescendantAnswerDetailsTable < FormulaAnswerDetailsTable
    @columns = ["Rank", "Ancestor Metric", "Value"]

    def table_rows
      @row_index = 0
      super
    end

    def metric_row input_card, value, _options
      @row_index += 1
      [@row_index,
       metric_thumbnail(input_card),
       link_to_answer(input_card, value, year)]
    end
  end
end
