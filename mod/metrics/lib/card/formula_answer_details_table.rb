class Card
  class CalculatedAnswerDetailsTable < AnswerDetailsTable
    @columns = ["Metric", "Value", "Year"]

    def calculator
      @calculator ||=
        Formula::Calculator.new @format.card.metric_card.formula_card
    end

    def table_rows
      calculator.input_data.map do |input_card, input, year_option|
        metric_row(input_card, input, year_option)
      end
    end

    #FIXME: not ready
    def metric_row input_card, input, year_option
      [metric_thumbnail(input_card), input,year_option]
    end

    def format_input_values
      kl
    end
  end
end
