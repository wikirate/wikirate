class Card
  class VegaChart
    # Company count charts with one bar per (numeric) value
    class NumberChart < VerticalBars
      def generate_data
        @filter_query.count_by_group(:numeric_value).each do |num, count|
          next unless num # exclude nil group
          add_data @format.humanized_number(num), count, num
        end
      end

      private

      # @return true if the bar given by its filter
      #   is supposed to be highlighted
      def highlight? value
        return true unless @highlight_value

        @highlight_value.to_d == value
      end
    end
  end
end
