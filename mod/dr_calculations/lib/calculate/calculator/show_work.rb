class Calculate
  class Calculator
    # supports displaying the workings of a given answer calculation
    module ShowWork
      # All the inputs for a given answer (the calculator implies the metric)
      # @param [Integer, String, Card] company (any company mark)
      # @param [String] year four-digit year
      # @return [Array] [[metric_card_1, value_1, year_options_1], [metric_card2...], ...]
      def inputs_for company, year
        @parser.input_cards.zip(
          Array.wrap(uncasted_input.input_for(company, year)), @parser.year_options
        )
      end

      # The formula for a given answer (the calculator implies the metric)
      # @param [Integer, String, Card] company (any company mark)
      # @param [String] year four-digit year
      # @param [Proc] block . Block that can handle three args:
      #     1: raw input value
      #     2. input metric card
      #     3. the year option
      # @return [String] the formula with nests replaced by the result of the given block
      def formula_for company, year, &block
        input_val = uncasted_input.input_for company, year
        case input_val
        when :unknown
          "Unknown"
        when nil
          "No value"
        else
          formula_with_nests input_val, &block
        end
      end

      private

      def uncasted_input
        @uncasted_input ||= with_input_cards { Input.new @parser, &method(:no_cast) }
      end

      def no_cast val
        val
      end

      def formula_with_nests input_val
        input_enum = input_val.each
        replace_nests do |index|
          yield input_enum.next, @parser.input_cards[index], @parser.year_options[index]
        end
      end

      def replace_nests content=nil
        content ||= formula
        index = -1
        content.gsub(/{{[^{}]*}}/) do |_match|
          index += 1
          yield(index)
        end
      end
    end
  end
end
