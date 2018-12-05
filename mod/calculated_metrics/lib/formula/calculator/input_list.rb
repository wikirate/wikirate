module Formula
  class Calculator
    class InputList < Array
      attr_reader :input_values
      delegate :all_input_required?, :value_store, to: :input_values

      def initialize input_values
        @input_values = input_values
        @input_cards = input_values.input_cards
        @input_cards.size.times.map do |i|
          add_item i
        end
      end

      def add_item i
        item = item_class(item_card).new(self, i)
        item.extend AllRequired if @input_values.all_input_required?
        item.extend YearOption if ¡
        self << item
      end

      def item_class input_card
        if input_card.type_id == Card::YearlyVariableID
          YearlyVariable
        else
          Metric
        end
      end
    end
  end
end
