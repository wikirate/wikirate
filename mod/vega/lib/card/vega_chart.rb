class Card
  # generate JSON for Vega visualizations
  class VegaChart
    include ChartColors
    include Axes

    class << self
      BUCKETS = 10

      def chart_class format, horizontal_ok=true
        card = format.card
        if card.numeric? || card.relationship?
          numeric_chart_class format, horizontal_ok
        elsif card.categorical?
          VegaChart::CategoryChart
        else
          raise Card::Error, "VegaChart not supported for #{card.name}"
        end
      end

      def numeric_chart_class format, horizontal_ok
        if horizontal_ok && format.chart_item_count <= BUCKETS
          VegaChart::HorizontalNumberChart
        elsif format.card.ten_scale?
          VegaChart::TenScaleChart
        # elsif format.chart_value_count <= BUCKETS
        #  VegaChart::NumberChart
        else
          VegaChart::RangeChart
        end
      end

      def json_from_file filename
        File.read File.expand_path("../vega_chart/json/#{filename}.json", __FILE__)
      end

      def builtin filename
        @builtin ||= {}
        @builtin[filename] ||=
          JSON.parse(json_from_file(filename)).deep_symbolize_keys.freeze
      end
    end

    delegate :builtin, to: :class

    # @param opts [Hash] config options
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

      @layout = opts.delete(:layout) || {}
      @opts = opts
      generate_data
    end

    def to_json
      to_hash.to_json
    end

    def to_hash
      layout.merge(data: data, scales: scales, marks: marks, axes: [x_axis, y_axis])
    end

    private

    def layout
      builtin(:default_layout).merge @layout
    end

    def add_label label
      @labels << label
    end

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

    def metric_card
      @metric_card ||= Card[@metric_id]
    end
  end
end
