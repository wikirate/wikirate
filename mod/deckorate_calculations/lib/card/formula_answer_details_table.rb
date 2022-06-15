class Card
  # Renders the table with details for an answer of a formula metric
  class FormulaAnswerDetailsTable < AbstractAnswerDetailsTable
    @columns = %w[Variable Metric Value Year]

    def calculator
      @calculator ||= @format.card.metric_card.calculator :raw
    end

    def table_rows
      calculator.inputs_for(company, year) do |input_card, value, options|
        metric_row input_card, value, options
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
      @format.modal_link input_value(input),
                         path: { mark: [input_card.name, company, year].to_name },
                         class: "metric-value",
                         size: :xl
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

    def metric_row input_card, value, options
      year_option = options[:year]
      [options[:name],
       metric_thumbnail(input_card),
       value_column_content(input_card, value, year_option),
       year_column_content(year_option)]
    end
  end
end
