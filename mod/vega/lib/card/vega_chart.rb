class Card
  # generate JSON for Vega visualizations
  class VegaChart
    class << self
      # VegaChart.new :chart_class, format, opts
      def new *args
        return super unless self == VegaChart

        chart_class = args.shift
        const_get(chart_class.to_s.camelize).new *args
      end

      def builtin filename
        @builtin ||= {}
        @builtin[filename] ||= prepare_builtin filename
        @builtin[filename].deep_dup
      end

      private

      def json_from_file filename
        File.read File.expand_path("../vega_chart/json/#{filename}.json", __FILE__)
      end

      def prepare_builtin filename
        JSON.parse(json_from_file(filename)).deep_symbolize_keys.freeze
      end
    end

    attr_reader :format
    delegate :builtin, to: :class

    def render
      method = Card.config.compress_javascript ? :generate : :pretty_generate
      JSON.send method, hash
    end

    def hash
      layout
    end

    # @param opts [Hash] config options
    # @option opts [String] :highlight highlight the bar for the given value
    # @option opts [Hash] :layout override DEFAULT_LAYOUT
    def initialize format, opts={}
      @format = format
      @highlight_value = opts[:highlight]
      @layout = opts[:layout] || {}
    end

    private

    def layout
      builtin(:default_layout).merge @layout
    end

    def multiyear?
      !format.filter_hash["year"].present?
    end
  end
end
