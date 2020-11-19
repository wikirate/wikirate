class Card
  class VegaChart
    class SingleMetric
      # Company count histograms.  Each vertical bar represents a range of values
      class Histogram < VerticalBars
        DEFAULT_BAR_CNT = 10

        def data_map
          { answers: :compact_answers }
        end

        private

        def x_axis
          super.merge scale: "x_label", format: "~s", title: title_with_unit("Ranges")
        end

        def scales
          super << x_label_scale
        end

        def x_label_scale
          { name: "x_label", type: "point", range: "width", domain: @labels }
        end

        def highlight? value
          return true unless @highlight_value
          @highlight_value >= value[:from] && @highlight_value < value[:to]
        end
      end
    end
  end
end
