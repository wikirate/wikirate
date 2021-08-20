module Formula
  class Calculator
    # {InputList} is an array of {InputItem}s.
    # It chooses the right InputItem class depending on the cardtype of the input item.
    class InputList < Array
      attr_reader :input
      delegate :parser, :input_cards, to: :input

      def initialize input
        @input = input
        @errors = []
        input_cards.size.times(&method(:add_item))
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

      def add_item i
        item = item_class(i).new(self, i)
        self << item
      end

      private

      def item_class i
        input_card = input_cards[i]
        input_card.type_id == Card::MetricID ? InputItem::MetricInputItem : InputItem::InvalidInputItem
      end
    end
  end
end
