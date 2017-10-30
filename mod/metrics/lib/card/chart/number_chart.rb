class Card
  # chart for numeric metrics
  # one bar per value
  module Chart
    # generates chart with one bar per (numeric) value
    class NumberChart < VegaChart
      def generate_data
        @filter_query.where.order(:numeric_value).each do |ma|
          add_data numeric_value: ma.numeric_value if ma.numeric_value
        end
      end

      private

      def data_item_hash filter
        super.merge x: @format.humanized_number(filter[:numeric_value])
      end

      def x_axis
        super.merge title: "Values"
      end

      # @return true if the bar given by its filter
      #   is supposed to be highlighted
      def highlight? filter
        return true unless @highlight_value
        @highlight_value.to_d == filter[:numeric_value]
      end

      def highlight_value_from_filter_opts filter_opts
        filter_opts[:numeric_value]
      end
    end
  end
end
