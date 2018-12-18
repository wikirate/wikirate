module Formula
  class Calculator
    # {InputList} is an array of {InputItem}s.
    # It chooses the right InputItem class depending on the cardtype of the input item.
    class InputList < Array
      INPUT_ITEM_CLASS_MAP =
        { Card::YearlyVariableID => InputItem::YearlyVariableInputItem,
          Card::MetricID => InputItem::MetricInputItem }.freeze

      attr_reader :input_values
      delegate :all_input_required?, :value_store, :companies_with_values,
               to: :input_values

      def initialize input_values
        @input_values = input_values
        #Array.new input_values.input_cards.size, &method(:add_item)
        @input_values.input_cards.size.times do |i|
          add_item i
        end
      end

      def add_item i
        item = item_class(i).new(@input_values, i, @input_values.all_input_required?)
        self << item
      end

      def item_class i
        input_card = @input_values.input_cards[i]
        INPUT_ITEM_CLASS_MAP[input_card.type_id] || InputItem::InvalidInput
      end
    end
  end
end
