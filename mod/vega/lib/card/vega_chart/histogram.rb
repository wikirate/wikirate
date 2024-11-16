class Card
  class VegaChart
    # Company count histograms.  Each vertical bar represents a range of values
    class Histogram < VegaChart
      include Helper::VerticalBar

      def hash
        with_values(record_list: 0) { super }.tap do |hash|
          hash[:signals] << { name: "extent", init: extent }
        end
      end

      private

      def extent
        "[data('valueExtremes')[0].min_value, data('valueExtremes')[0].max_value]"
      end

      def layout
        super.merge builtin(:histogram)
      end

      def x_axis
        super.merge title: value_title, format: ",~r" # number formatting
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
