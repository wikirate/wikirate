module Formula
  class Calculator
    class InputItem
      attr_reader :card_id, :input_list
      delegate :company_list, :all_input_required?, to: :input_list

      def initialize input_list, input_index
        @input = input_values.input
        @input_index = input_index
        @input_card = input.input_cards[input_index]
        @card_id = @input_card.id
        initialize_decorator
      end

      def initialize_decorator

      end

      def add_value

      end

      def year_option?
        year_option.present?
      end

      def company_option?
        company_option.present?
      end

      def year_option
        @year_option ||= @input.year_options_processor[@input_index]
      end

      def company_option
        @company_option ||= @input.company_options.processor[@input_index]
      end
    end
  end
end
