module Formula
  class Calculator
    class InputList < Array
      attr_reader :input_values
      delegate :all_input_required?, :value_store, :companies_with_values,
               to: :input_values

      def initialize input_values
        @input_values = input_values
        Array.new input_values.input_cards.size, &method(:add_item)
      end

      def add_item i
        item = item_class(i).new(@input_values, i, @input_values.all_input_required?)
        # item.extend InputItem::AllRequired if @input_values.all_input_required?
        # item.extend YearOption if
        # item.extend CompanyOption if
        self << item
      end

      def item_class i
        input_card = @input_values.input_cards[i]
        if input_card.type_id == Card::YearlyVariableID
          InputItem::YearlyVariableInput
        else
          InputItem::MetricInput
        end
      end
    end
  end
end
