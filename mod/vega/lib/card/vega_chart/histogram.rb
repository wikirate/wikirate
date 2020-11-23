class Card
  class VegaChart
    # Company count histograms.  Each vertical bar represents a range of values
    class Histogram < VegaChart
      include Helper::SingleMetric
      include Helper::Axes
      include Helper::Highlight

      def hash
        with_values(answer_list: 0) { super }.tap do |hash|
          hash[:signals] << { name: "extent", init: extent }
        end
      end

      private

      def extent
        "[data('extremes')[0].min_value, data('extremes')[0].max_value]"
      end

      def layout
        super.merge builtin(:histogram)
      end

      def x_axis
        super.merge title: value_title, format: "~s" # number formatting
      end

      def y_axis
        super.merge count_axis
      end

      def highlight_transform
        super.tap do |t|
          t[:expr] = "(highlight >= datum.bin0 && highlight < datum.bin1) " \
                     "|| datum.bin1 == toNumber(highlight)"
        end
      end
    end
  end
end
