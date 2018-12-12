module Formula
  class Calculator
    class InputItem
      # Manages the two different types of input values: metrics and yearly variables
      class YearlyValueStore < ValueStore

        def initialize
          @years = ::Set.new
          @values = Hash.new_nested(Hash)
        end

        def get company, year=nil
          year ? values[year] : values
        end

        def companies
          @values.keys
        end

        def add *args
          value = args.pop
          year = args.pop
          @years.add year
          values.merge!(year.to_i => value)
        end
      end
    end
  end
end
