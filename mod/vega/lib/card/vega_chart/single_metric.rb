class Card
  # generate JSON for Vega visualizations
  class VegaChart
    class SingleMetric < VegaChart
      BUCKETS = 10

      class << self
        def new format, metric_card, opts={}
          return super unless self == SingleMetric

          chart_class = metric_card.chart_class opts.delete(:horizontal)
          const_get(chart_class.to_s.camelize).new format, metric_card, opts
        end
      end

      attr_reader :metric_card

      # @param opts [Hash] config options
      # @option opts [String] :highlight highlight the bar for the given value
      # @option opts [Hash] :layout override DEFAULT_LAYOUT
      # @option opts [:light/:dark] :axes color of axes, labels and titles
      def initialize format, metric_card, opts={}
        @format = format
        @metric_card = metric_card
        @filter_query = format.chart_filter_query
        @highlight_value = opts[:highlight]
        @layout = opts.delete(:layout) || {}
        @data = []
        @labels = []
        @opts = opts
        generate_data
      end

      private

      def data
        [{ name: "table", values: @data }]
      end

      def marks
        hash = main_mark.clone
        hash[:encode].merge! update: { fill: fill_color },
                             hover: { fill: { value: ChartColors::HOVER_COLOR },
                                      cursor: { value: hover_cursor } }
        [hash]
      end

      def hover_cursor
        "pointer"
      end

      def scales
        [x_scale, y_scale, color_scale]
      end

      def x_scale
        { name: "xscale", range: "width", domain: { data: "table", field: "xfield" } }
      end

      def y_scale
        { name: "yscale", range: "height", domain: { data: "table", field: "yfield" } }
      end
    end
  end
end
