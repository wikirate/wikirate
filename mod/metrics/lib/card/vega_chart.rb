class Card
  # generate JSON for Vega visualizations
  class VegaChart
    include ChartColors

    class << self
      BUCKETS = 10

      def chart_class format
        card = format.card
        if card.ten_scale?
          TenScaleChart
        elsif card.numeric? || card.relationship?
          numeric_chart_class format
        elsif card.categorical?
          CategoryChart
        else
          raise Card::Error, "VegaChart not supported for #{card.name}"
        end
      end

      def numeric_chart_class format
        if format.chart_item_count <= BUCKETS
          NumberChart # HorizontalNumberChart
        elsif format.chart_value_count <= BUCKETS
          NumberChart
        else
          RangeChart
        end
      end

      def hash_from_json filename
        json = File.read(File.expand_path("../vega_chart/json/#{filename}.json", __FILE__))
        JSON.parse(json).deep_symbolize_keys.freeze
      end
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
      { y: count, filter: filter, highlight: highlight?(filter) }
    end

    def data
      [{ name: "table", values: @data }]
    end

    def marks
      hash = DEFAULT_MARKS.clone
      hash[:encode].merge! update: { fill: fill_color },
                           hover: { fill: { value: ChartColors::HOVER_COLOR },
                                    cursor: { value: hover_cursor } }
      [hash, TOOLTIP_MARK]
    end

    def hover_cursor
      "pointer"
      # click_action == :zoom ? "zoom-in" : "pointer"
    end

    def axes
      [x_axis, y_axis]
    end
  end
end
