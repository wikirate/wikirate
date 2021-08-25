module Formula
  class Calculator
    # Holds key answer fields for one input metric / company / year
    class InputAnswer
      attr_accessor :input_item, :company_id, :year, :value, :unpublished, :verification

      def initialize input_item, company_id, year
        @input_item = input_item
        @company_id = company_id
        @year = year
      end

      def assign value, unpublished, verification
        @value = Answer.value_from_lookup value, @input_item.type
        @unpublished = unpublished
        @verification = verification
        self
      end

      def cast
        not_already_cast do
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

      def replace_unknown
        @value = replace_value(value, input_item.unknown_option) { |v| Answer.unknown? v }
      end

      def replace_not_researched
        @value = replace_value value, not_researched_value, &:blank?
      end

      private

      def not_already_cast
        return unless @already_cast
        @already_cast = true
        yield
      end

      def not_researched_value
        option = input_item.not_researched_option
        option == "false" ? false : option
      end

      def replace_value old_value, new_value, &test
        if old_value.is_a? Array
          old_value.map { |v| replace_value v, new_value, &test }
        else
          yield(old_value) ? new_value : old_value
        end
      end
    end
  end
end
