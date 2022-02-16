class Calculate
  class Calculator
    # {InputList} is an array of {InputItem}s.
    # It chooses the right InputItem class depending on the cardtype of the input item.
    class InputList < Array
      def initialize input_hash
        @errors = []
        count = input_hash.keys.count
        input_hash.each_with_index do |(id, options), index|
          card = id.card
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
          @errors <<
            "there must be at least one nest that doesn't explicitly specify companies"
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
        puts "add_item: #{card}, #{args}"
        self << InputItem.item_class(card.type_id).new(card, *args)
      end
    end
  end
end
