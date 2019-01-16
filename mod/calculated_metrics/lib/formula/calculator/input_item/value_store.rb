module Formula
  class Calculator
    class InputItem
      # Used to hold onto the values that an input item finds
      class ValueStore
        attr_reader :years, :values, :companies
        def initialize
          @years = ::Set.new
          @companies = ::Set.new  # all company
          @values = Hash.new_nested(Hash, Hash)
        end

        # @return [Hash]
        #   { company_id => { year => value } if company is nil and year is nil or missing
        #   { year => value }                 if year is nil or missing
        #   value                             if both are present
        def get company, year=nil
          dig_args = [company, year].compact
          ret = dig_args.present? ? values.dig(*dig_args) : values
          ret unless ret.empty?
        end

        def add company, year, value
          @years.add year
          @companies.add company
          values[company].merge!(year.to_i => value)
        end
      end
    end
  end
end
