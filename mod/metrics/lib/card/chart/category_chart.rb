class Card
  module Chart
    # chart for categorical metrics
    # shows companies   per category
    class CategoryChart < VegaChart
      def generate_data
        Card[@metric_id].value_options.each do |category|
          add_data category: category
        end
      end

      def click_action
        :select
      end

      private

      def x_axis
        super.deep_merge title: "Categories",
                         encode: { labels: { update: { angle: { value: 30 },
                                                       limit: { value: 70 },
                                                       align: { value: "left" } } } }
      end

      def data_item_hash filter
        super.merge x: filter[:category]
      end

      # @return true if the bar given by its filter
      #   is supposed to be highlighted
      def highlight? filter
        return true unless @highlight_value
        @highlight_value == filter[:category]
      end

      def highlight_value_from_filter_opts filter_opts
        filter_opts[:category]
      end
    end
  end
end
