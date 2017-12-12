class Card
  class FormulaAnswerDetailsTable < AbstractAnswerDetailsTable
    @columns = ["Metric", "Value", "Year"]

    def calculator
      @calculator ||=
        Formula::Calculator.new @format.card.metric_card.formula_card
    end

    def table_rows
      calculator.input_data(company, year).map do |input_card, input, year_option|
        metric_row input_card, input, year_option
      end
    end

    def raw_value input
      @format.wrap_with :span, class: "metric-value" do
        Array.wrap(input).join(", ")
      end
    end

    def year_column_content year_option
      year_option.present? ? year_option : year
    end

    def metric_row input_card, input, year_option
      [metric_thumbnail(input_card),
       raw_value(input),
       year_column_content(year_option)]
    end
  end
end
