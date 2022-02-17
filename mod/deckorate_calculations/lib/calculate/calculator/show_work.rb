class Calculate
  class Calculator
    # supports displaying the workings of a given answer calculation
    module ShowWork
      # All the inputs for a given answer (the calculator implies the metric)
      # @param [Integer, String, Card] company (any company mark)
      # @param [String] year four-digit year
      # @return [Array] [[metric_card_1, value_1, year_options_1], [metric_card2...], ...]
      def inputs_for company, year
        values = Array.wrap uncast_input.input_for(company, year)
        uncast_input.input_list.map.with_index do |input_item, index|
          [input_item.input_card,
           values[index],
           input_item.try(:year_option) ]
        end
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
        input_val = uncast_input.input_for company, year
        case input_val
        when :unknown
          "Unknown"
        when nil
          "No value"
        else
          "#formula_for FIXME!!!"
        end
      end

      private

      def uncast_input
        @uncast_input ||= input_with :no_cast
      end

      def no_cast val
        val
      end
    end
  end
end
