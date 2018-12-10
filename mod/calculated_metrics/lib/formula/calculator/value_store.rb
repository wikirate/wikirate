module Formula
  class Calculator
    # Manages the two different types of input values: metrics and yearly variables
    class ValueStore
      def initialize company_dependent
        @with_companies = company_dependent
        @years = ::Set.new
        @values = company_dependent ? Hash.new_nested(Hash, Hash) : Hash.new_nested(Hash)
      end

      def get company, year=nil
        dig_args = [(company if @with_companies), year].compact
        values.dig(*dig_args)
      end

      def companies
        @values.keys
      end

      def years
        @years
      end

      def add *args
        value = args.pop
        year = args.pop
        @years.add year
        values.dig(*args).merge!(year.to_i => value)
      end

      def values
        @values
      end
    end
  end
end
