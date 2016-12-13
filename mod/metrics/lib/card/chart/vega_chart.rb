class Card
  module Chart
    class VegaChart
      BAR_COLOR = "#eeeeee"
      HIGHLIGHT_COLOR = "#674ea7"
      HOVER_COLOR = "#b3a7d3"
      DARK_AXES = "#333333"
      LIGHT_AXES = "#cccccc"

      DEFAULT_LAYOUT = {
        width: 400,
        height: 200,
        padding: { top: 30, left: 50, bottom: 50, right: 50 }
      }.freeze

      DEFAULT_MARKS = {
        type: "rect",
        from: { data: "table" },
        properties:
          { enter:
              { x: { scale: "x", field: "x" },
                width: { scale: "x", band: true, offset: -1 },
                y: { scale: "y", field: "y" },
                y2: { scale: "y", value: 0 } }
          }
      }.freeze

      # @param opts [Hash] config options
      # @option opts [Boolean] :link make bars clickable
      # @option opts [String] :highlight highlight the bar for the given value
      # @option opts [Hash] :layout override DEFAULT_LAYOUT
      # @option opts [:light/:dark] :axes color of axes, labels and titles
      def initialize format, opts={}
        @format = format
        @metric_id = format.chart_metric_id
        @filter_query = format.chart_filter_query
        @highlight_value = opts[:highlight]
        @data = []
        @labels = []
        @max_count = 0
        @opts = opts
        generate_data
      end

      def to_json
        to_hash.to_json
      end

      def to_hash
        layout.merge(data: data,
                     scales: scales,
                     marks: marks,
                     axes: axes)
      end

      private

      def count filter
        count = @filter_query.count filter
        @max_count = count if count > @max_count
        count
      end

      def layout
        @opts[:layout] ? DEFAULT_LAYOUT.merge(@opts[:layout]) : DEFAULT_LAYOUT
      end

      def add_data filter
        @data << data_item_hash(filter)
      end

      def data_item_hash filter
        hash = { y: count(filter),
                 highlight: highlight?(filter) }
        hash[:link] = filter_link filter if @opts[:link]
        hash
      end

      def data
        [{ name: "table", values: @data }]
      end

      def scales
        [x_scale, y_scale, color_scale]
      end

      def x_scale
        { name: "x",
          type: "ordinal",
          range: "width",
          domain: { data: "table", field: "x" } }
      end

      def y_scale
        scale = { name: "y",
                  type: "linear",
                  range: "height",
                  domain: { data: "table", field: "y" },
                  round: true }

        # vega shows non-integer labels on the y-axis if
        # the counts are not big enough
        # (that doesn't make sense for a company count)
        scale[:domainMax] = 8 if @max_count < 8
        scale
      end

      #  used for highlighting
      def color_scale
        {
          "name": "color",
          "type": "ordinal",
          "domain": {
            "data": "table",
            "field": "highlight",
            "sort": true
          },
          "range": [BAR_COLOR, HIGHLIGHT_COLOR]
        }
      end

      def marks
        hash = DEFAULT_MARKS.clone
        hash[:properties][:update] = { fill: fill_color }
        hash[:properties][:hover] = { fill: { value: HOVER_COLOR } } if link?
        [hash]
      end

      def link?
        @opts[:link]
      end

      def fill_color
        if @highlight_value
          { scale: "color", "field": "highlight" }
        else
          { value: HIGHLIGHT_COLOR }
        end
      end

      def axes
        [x_axis, y_axis]
      end

      def x_axis
        { type: "x", scale: "x", title: "Values",
          properties: axes_properties }
      end

      def y_axis
        { type: "y", scale: "y", title: "Companies",
          properties: axes_properties }
      end

      def axes_properties
        color = @opts[:axes] == :light ? LIGHT_AXES : DARK_AXES
        {
          title: {
            fill: { value: color }
          },
          axis: {
            stroke: { value: color }
          },
          ticks: {
            stroke: { value: color }
          },
          labels: {
            fill: { value: color }
          }
        }
      end

      def filter_link filter_opts
        @format.path view: :data, filter: filter_opts.merge(@format.filter_hash)
      end
    end
  end
end
