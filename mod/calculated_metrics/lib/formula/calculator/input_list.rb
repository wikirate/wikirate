module Formula
  class Calculator
    # {InputList} is an array of {InputItem}s.
    # It chooses the right InputItem class depending on the cardtype of the input item.
    class InputList < Array
      INPUT_ITEM_CLASS_MAP =
        { Card::YearlyVariableID => InputItem::YearlyVariableInputItem,
          Card::MetricID         => InputItem::MetricInputItem }.freeze

      attr_reader :parser

      def initialize parser
        @parser = parser
        @input_cards = parser.input_cards
        #Array.new input_values.input_cards.size, &method(:add_item)
        @input_cards.size.times(&method(:add_item))
      end

      def no_mandatories?
        return @no_mandatories unless @no_mandatories.nil?
        @no_mandatories = all? { |item| !item.mandatory? }
      end

      def add_item i
        item = item_class(i).new(self, i)
        self << item
      end

      def item_class i
        input_card = @input_cards[i]
        INPUT_ITEM_CLASS_MAP[input_card.type_id] || InputItem::InvalidInput
      end
    end
  end
end
