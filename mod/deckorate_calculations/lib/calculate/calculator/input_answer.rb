class Calculate
  class Calculator
    # Holds key answer fields for one input metric / company / year
    class InputAnswer
      attr_accessor :lookup_ids, :input_item,
                    :company_id, :year, :value,
                    :unpublished, :verification

      def initialize input_item, company_id, year
        @input_item = input_item
        @company_id = company_id
        @year = year
      end

      def assign lookup_ids, value, unpublished, verification
        @lookup_ids = Array.wrap lookup_ids
        @value = Answer.value_from_lookup value, @input_item.type
        @unpublished = unpublished
        @verification = verification
        self
      end

      def cast &block
        not_already_cast do
          @value =
            case @value
            when Array
              cast_array(&block)
            when Symbol
              @value
            else
              standard_cast(&block)
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

      def cast_array
        @value.map { |v| yield v }
      end

      def standard_cast
        @value.blank? ? nil : yield(@value)
      end

      def not_already_cast
        return if @already_cast
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
