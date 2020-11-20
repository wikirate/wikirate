class Card
  class VegaChart
    class SingleMetric
      # Company count histograms.  Each vertical bar represents a range of values
      class Histogram < SingleMetric
        include Axes
        include AnswerValues

        def to_hash
          layout.merge(data).tap do |hash|
            hash[:signals] << { name: "extent", init: extent }
          end
        end

        private

        def extent
          "[data('extremes')[0].min_value, data('extremes')[0].max_value]"
        end

        def data
          with_answer_values { builtin :histogram_data }
        end

        def layout
          super.merge builtin(:histogram)
        end

        def x_axis
          super.merge title: x_title, format: "~s" # number formatting
        end

        def x_title
          title_with_unit "Value"
        end

        def y_axis
          super.merge count_axis
        end

        def highlight? value
          return true unless @highlight_value
          @highlight_value >= value[:from] && @highlight_value < value[:to]
        end
      end
    end
  end
end
