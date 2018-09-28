module Formula
  class Wolfram < Calculator
    # Provide methods to handle "Unknown" input values for Wolfram formulas
    module Unknowns
      # what to do if an input value is unknown
      # currently hard-coded.
      # We probably want this sharkable
      UNKNOWN_STRATEGY = :reject # reject:  calculated value is nil
                                 # unknown: calculated value is unknown
                                 # pass:    pass "Unknown" as String to the formula;
                                 #          the formula has to deal with it

      def handle_unknowns company, year
        @unknown_input ||= Hash.new_nested Array
        catch(:unknown) do
          yield
          return
        end
        @unknown_input[year.to_s] << company
      end

      def unknown_value
        @unknown_value ||= unknown_strategy == :unknown ? "Unknown" : nil
      end

      def unknown_strategy
        UNKNOWN_STRATEGY
      end

      def insert_unknowns values_by_year
        return values_by_year unless @unknown_input.present?

        @unknown_input.each_pair do |year, companies|
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
