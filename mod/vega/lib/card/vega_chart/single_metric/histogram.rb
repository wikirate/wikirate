class Card
  class VegaChart
    class SingleMetric
      # Company count histograms.  Each vertical bar represents a range of values
      class Histogram < SingleMetric
        DEFAULT_BAR_CNT = 10

        def data_map
          { answers: :compact_answers }
        end

        def to_hash
          layout.merge(data: data).tap do |hash|
            hash[:signals] << { name: "extent", init: extent }
          end
        end

        private

        def extent
          "[data('extremes')[0].min_value, data('extremes')[0].max_value]"
        end

        def data
          (super + builtin(:histogram_transforms)[:data].deep_dup).tap do |array|
            array.first["transform"] =
              [{ type: "formula", as:"value", expr: "toNumber(datum.value)" }]
          end
        end

        def layout
          super.merge(builtin(:histogram)).deep_dup
        end

        def highlight? value
          return true unless @highlight_value
          @highlight_value >= value[:from] && @highlight_value < value[:to]
        end
      end
    end
  end
end
