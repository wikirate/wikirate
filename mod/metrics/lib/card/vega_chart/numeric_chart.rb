class Card
  class VegaChart
    class NumericChart < VegaChart
      BUCKETS = 10

      def self.new format, opts
        chart_type(format, opts).new format, opts
      end

      def self.chart_type format, opts
        if format.chart_item_count <= BUCKETS ||
           format.chart_value_count <= BUCKETS
          NumberChart
        else
          opts[:buckets] = BUCKETS
          RangeChart
        end
      end
    end
  end
end
