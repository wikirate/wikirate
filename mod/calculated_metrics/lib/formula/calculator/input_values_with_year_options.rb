module Formula
  class Calculator
    class InputValuesWithYearOptions < InputValues
      def fetch company:, year:
        values_for_all_years = super company: company, year: nil
        @input.year_options_processor.run values_for_all_years, year
      end
    end
  end
end
