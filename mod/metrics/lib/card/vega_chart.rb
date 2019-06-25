class Card
  class VegaChart
    BAR_COLOR = "#eeeeee".freeze
    HIGHLIGHT_COLOR = "#F78C1E".freeze
    HOVER_COLOR = "#D3741C".freeze
    DARK_AXES = "#333333".freeze
    LIGHT_AXES = "#cccccc".freeze

    def self.hash_from_json filename
      json = File.read(File.expand_path("../vega_chart/json/#{filename}.json", __FILE__))
      JSON.parse(json).deep_symbolize_keys.freeze
    end

    DEFAULT_LAYOUT = hash_from_json "default_layout"
    DEFAULT_MARKS = hash_from_json "default_marks"
    TOOLTIP_MARK = hash_from_json "tooltip_mark"
    # show the value on top of the bar on mouse over
    # (needs the "signal" section in DEFAULT_LAYOUT)

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

    def layout
      DEFAULT_LAYOUT.merge @layout
    end

    def add_data filter, count
      @data << data_item_hash(filter, count)
      @y_range.add @data.last[:y]
      @data
    end

    def add_label label
      @labels << label
    end

    def data_item_hash filter, count
      hash = { y: count, highlight: highlight?(filter) }
      hash[:link] = bar_link(filter) if link?
      hash
    end

    def data
      [{ name: "table", values: @data }]
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
      [hash, TOOLTIP_MARK]
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

    def diagonal_x_labels?
      true
    end

    def diagonalize encode
      return unless diagonal_x_labels?

      encode.deep_merge! labels: { update: { angle: { value: 30 },
                                             limit: { value: 70 },
                                             align: { value: "left" } } }
    end

    def axes_encode
      color = @opts[:axes] == :light ? LIGHT_AXES : DARK_AXES
      { title:  { fill:   { value: color } },
        domain: { stroke: { value: color } },
        ticks:  { stroke: { value: color } },
        labels: { fill:   { value: color } } }
    end

    # return the url to the link target of a bar in the chart
    # :filter has the filter options for the table
    # :chart[:filter] the filter options for the chart
    def bar_link filter_opts
      @format.path bar_link_params(filter_opts).merge(view: :filter_result)
    end

    def bar_link_params filter_opts
      case click_action
      when :select
        bar_select_link_params filter_opts
      when :zoom
        bar_zoom_link_params filter_opts
      end
    end

    def bar_select_link_params filter_opts
      hash = {
        filter: @format.filter_hash.merge(filter_opts),
        chart: {
          highlight: highlight_value_from_filter_opts(filter_opts),
          select_filter: filter_opts,
          filter: @format.filter_hash(false),
          zoom_level: zoom_level
        }
      }
      if @format.chart_params[:zoom_out]
        hash[:chart][:zoom_out] = @format.chart_params[:zoom_out]
      end
      hash
    end

    def bar_zoom_link_params filter_opts
      {
        filter: @format.filter_hash(false).merge(filter_opts),
        chart: {
          zoom_level: zoom_level + 1,
          zoom_out: {
            chart: @format.chart_params,
            filter: @format.filter_hash(false)
          }
        }
      }
    end

    def zoom_level
      @format.chart_params[:zoom_level].to_i || 0
    end
  end
end