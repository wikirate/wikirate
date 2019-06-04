module Formula
  class Calculator
    class InputItem
      # Provides the same api as ValueStore but ignores the company arguments
      class YearlyValueStore < ValueStore
        def initialize
          @years = ::Set.new
          @companies = ::Set.new  # for compatibility reasons; always empty
          @values = Hash.new_nested(Hash)
        end

        # @return [Hash]
        #   { year => value } if year is nil or missing
        #   value             if year is present
        def get _company, year=nil
          year ? values[year] : values
        end

        def add _company, year, value
          @years.add year
          values[year.to_i] = value
        end
      end
    end
  end
end
