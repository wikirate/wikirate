module Formula
  class Calculator
    # Holds key answer fields for one input metric / company / year
    class InputAnswer
      attr_accessor :company_id, :year, :value, :unpublished, :verification

      def initialize input_item, company_id, year
        @input_item = input_item
        @company_id = company_id
        @year = year
      end

      def assign value, unpublished, verification
        @value = value
        @unpublished = unpublished
        @verification = verification
        self
      end

      def normalize
        @value = Answer.value_from_lookup value, @input_item.type
      end

      def cast
        @value =
          case @value
          when Array
            @value.map { |v| yield v }
          when Symbol
            @value
          else
            @value.blank? ? nil : yield(@value)
          end
      end
    end
  end
end
