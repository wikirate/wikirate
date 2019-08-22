class Card
  # Renders the table with details for an answer of a formula metric
  class FormulaAnswerDetailsTable < AbstractAnswerDetailsTable
    @columns = %w[Metric Value Year]

    def calculator
      @calculator ||=
        Formula::Calculator.new @format.card.metric_card.formula_card.parser.raw_input!
    end

    def table_rows
      calculator.input_data(company, year).map do |input_card, input, year_option|
        metric_row input_card, input, year_option
      end
    end

    def value_column_content input_card, input, year_option
      if (year = simple_year(year_option))
        link_to_answer input_card, input, year
      else
        value_span input
      end
    end

    def link_to_answer input_card, input, year
      @format.link_to_card [input_card.name, company, year].to_name,
                           input_value(input),
                           class: "metric-value _update-details"
    end

    def value_span input
      @format.wrap_with(:span, class: "metric-value") { input_value(input) }
    end

    def simple_year year_option
      year = year_column_content(year_option).to_s
      year.match?(/^\d{4}$/) ? year : nil
    end

    def input_value input
      Array.wrap(input).join(", ")
    end

    def year_column_content year_option
      year_option.present? ? year_option : year
    end

    def metric_row input_card, input, year_option
      [metric_thumbnail(input_card),
       value_column_content(input_card, input, year_option),
       year_column_content(year_option)]
    end
  end
end
