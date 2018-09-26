module Formula
  class Calculator
    class InputValuesWithYearOptions < InputValues
      def fetch company:, year:
        values_for_all_years = super company: company, year: nil
        @input.year_options_processor.run values_for_all_years, year
      end

      private

      def answer_query input_card_id, _year
        # since we need the values for all years to handle the year options,
        # there is no point in restricting the query to one year
        super(input_card_id, nil)
      end
    end
  end
end
