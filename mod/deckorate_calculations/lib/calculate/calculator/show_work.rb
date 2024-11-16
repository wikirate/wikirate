class Calculate
  class Calculator
    # supports displaying the workings of a given record calculation
    module ShowWork
      # All the inputs for a given record (the calculator implies the metric)
      # @param [Integer, String, Card] company (any company mark)
      # @param year [String] four-digit year
      # @return [Array] [[metric_card_1, value_1, year_options_1], [metric_card2...], ...]
      def inputs_for company, year
        values = Array.wrap uncast_input.input_for(company, year)
        uncast_input.input_list.map.with_index do |input_item, index|
          yield input_item.input_card, values[index], input_item.options
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
