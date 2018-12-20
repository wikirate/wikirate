module Formula
  class Wolfram < NestFormula
    # Provide methods to handle "Unknown" return values for Wolfram formulas
    module Unknowns
      # Deals with the "unknown: result_unknown" option for Wolfram formulas.
      # If the formula is supposed to return "Unknown" because of an
      # "Unknown" input value, then we have skip the calculation for that answer and
      # add the "Unknown" after we got the result from the Wolfram server
      def handle_unknowns input_values, company, year
        @unknown_result ||= Hash.new_nested Array
        if input_values == :unknown
          @unknown_result[year.to_s] << company
        else
          yield
        end
      end

      def insert_unknown_results values_by_year
        return values_by_year unless @unknown_result.present?

        @unknown_result.each_pair do |year, companies|
          companies.each do |company|
            values_by_year[year] ||= []
            add_company_index company, year, values_by_year[year].size
            values_by_year[year] << unknown_value
          end
        end
        values_by_year
      end
    end
  end
end
