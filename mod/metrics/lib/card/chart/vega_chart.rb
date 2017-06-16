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
        encode:
          { enter:
              { x: { scale: "x", field: "x" },
                width: { scale: "x", band: true, offset: -1 },
                y: { scale: "y", field: "y" },
                y2: { scale: "y", value: 0 } }
          }
      }.freeze

      Range = Struct.new(:min, :max) do
        def add value
          self.min = [min, value].compact.min
          self.max = [max, value].compact.max
        end

        def span
          return 0 unless max && min
          max - min
        end
      end

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

        @y_range = Range.new
        @layout = opts.delete(:layout) || {}
        @max_ticks = @layout.delete(:max_ticks)
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

      # determines what happens if you click on a bar in the chart
      # @return :zoom, :select or false (= no action)
      #   :select highlights the clicked bar and restrict the shown result
      #           to the companies of that bar
      #   :zoom restrict the shown result but also regenerate the
      #         chart for the restricted domain
      def click_action
        false
      end

      private

      def count filter
        count = @filter_query.count filter
        count
      end

      def layout
        DEFAULT_LAYOUT.merge @layout
      end

      def add_data filter
        @data << data_item_hash(filter)
        @y_range.add @data.last[:y]
        @data
      end
      def data_item_hash filter
        hash = { y: count(filter),
                 highlight: highlight?(filter) }
        hash[:link] = bar_link(filter) if link?
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
          type: "band",
          range: "width",
          domain: { data: "table", field: "x" } }
      end

      def y_scale
        scale = { name: "y",
                  type: y_type,
                  range: "height",
                  domain: { data: "table", field: "y" },
                  round: true }
        scale
      end

      def y_type
        @y_range.span > 100 ? "sqrt" : "linear"
      end

      # If the maximal value is less than 8 then vega shows
      # non-integers labels. We have to reduce the number of ticks
      # to the maximal value to avoid that
      # @max_ticks is a config option
      def y_tick_count
        return @max_ticks if @y_range.max && @y_range.max >= 8
        [@y_range.max, @max_ticks].compact.min
      end

      #  used for highlighting
      def color_scale
        {
          name: "color",
          type: "ordinal",
          domain: {
            data: "table",
            field: "highlight",
            sort: true
          },
          range: [BAR_COLOR, HIGHLIGHT_COLOR]
        }
      end

      def marks
        hash = DEFAULT_MARKS.clone
        hash[:encode][:update] = { fill: fill_color }
        if link?
          hash[:encode][:hover] = {
            fill: { value: HOVER_COLOR },
            cursor: { value: hover_cursor }
          }
        end
        [hash]
      end

      def hover_cursor
        click_action == :zoom ? "zoom-in" : "pointer"
      end

      def link?
        @opts[:link]
      end

      def fill_color
        if @highlight_value
          { scale: "color", field: "highlight" }
        else
          { value: HIGHLIGHT_COLOR }
        end
      end

      def axes
        [x_axis, y_axis]
      end

      def x_axis
        { orient: "bottom", scale: "x", title: "Values",
          encode: axes_encode }
      end

      def y_axis
        hash = { orient: "left", scale: "y",
                 title: "Companies",
                 encode: axes_encode }
        hash[:tickCount] = y_tick_count if y_tick_count
        hash
      end

      def axes_encode
        color = @opts[:axes] == :light ? LIGHT_AXES : DARK_AXES
        {
          title: {
            fill: { value: color }
          },
          domain: {
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

      # return the url to the link target of a bar in the chart
      # :filter has the filter options for the table
      # :chart[:filter] the filter options for the chart
      def bar_link filter_opts
        @format.path view: :content,
                     chart: bar_link_chart_params(filter_opts),
                     filter: @format.filter_hash(false)
      end

      def bar_link_chart_params filter_opts
        hash = { filter: filter_opts }
        case click_action
        when :select
          hash[:highlight] = highlight_value_from_filter_opts filter_opts
        when :zoom
          hash[:zoom_out] = @format.chart_params
        end
        hash
      end
    end
  end
end
