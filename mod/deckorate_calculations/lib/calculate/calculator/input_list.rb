class Calculate
  class Calculator
    # {InputList} is an array of {InputItem}s.
    # It chooses the right InputItem class depending on the cardtype of the input item.
    class InputList < Array
      def initialize input_array
        @errors = []
        count = input_array.count
        input_array.each_with_index do |options, index|
          card = options.delete(:metric).card
          add_item card, index, count, options
        end
      end

      # returns empty array if everything is ok
      def validate
        @errors = map(&:validate).compact.flatten
        check_nests
        @errors
      end

      def check_nests
        if empty?
          @errors << "at least one metric variable nest is required" if empty?
        elsif no_company_dependency?
          @errors << "must have at least one variable not explicitly specify company"
        end
      end

      def no_mandatories?
        return @no_mandatories unless @no_mandatories.nil?

        @no_mandatories = none?(&:mandatory?)
      end

      def no_company_dependency?
        return @no_company_dependency unless @no_company_dependency.nil?

        @no_company_dependency = none?(&:company_dependent?)
      end

      def add_item card, *args
        self << InputItem.item_class(card.type_id).new(card, *args)
      end
    end
  end
end
