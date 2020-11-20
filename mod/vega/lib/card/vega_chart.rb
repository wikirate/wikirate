class Card
  # generate JSON for Vega visualizations
  class VegaChart
    class << self
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

    delegate :builtin, to: :class

    def render
      JSON.pretty_generate to_hash
    end

    def to_hash
      layout.merge(data: data, scales: scales, marks: marks)
    end

    private

    def layout
      builtin(:default_layout).merge @layout
    end

    def multiyear?
      !format.filter_hash[:year].present?
    end
  end
end
