class Card
  # Renders the table with details for an answer of a Descendant metric
  class DescendantAnswerDetailsTable < FormulaAnswerDetailsTable
    @columns = ["Rank", "Ancestor Metric", "Value"]

    def table_rows
      @row_index = 0
      super
    end

    def metric_row input_card, input, year_option
      @row_index += 1
      [@row_index,
       metric_thumbnail(input_card),
       value_column_content(input_card, input, year_option)]
    end
  end
end
