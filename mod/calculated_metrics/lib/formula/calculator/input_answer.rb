module Formula
  class Calculator
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

      private

      def normalize_values val
        case val
        when Symbol
          val
        when Array
          val.map(&method(:normalize_values))
        else
          val.blank? ? nil : @input_cast.call(val)
        end
      end
    end
  end
end
