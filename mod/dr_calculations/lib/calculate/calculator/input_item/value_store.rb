class Calculate
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

        # @return [InputAnswer]
        def get company, year
          dig_args = [company, year].compact
          ret = dig_args.present? ? values.dig(*dig_args) : values
          ret if ret.present?
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
