class Card
  # generate JSON for Vega visualizations
  class VegaChart
    include ChartColors
    include Axes

    class << self
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
  end
end
