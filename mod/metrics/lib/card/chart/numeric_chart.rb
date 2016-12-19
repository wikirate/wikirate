class Card
  module Chart
    class NumericChart < VegaChart
      BUCKETS = 10

      def self.new format, opts
        chart_class =
          if format.chart_filter_query.count <= BUCKETS ||
             format.chart_filter_query.value_count <= BUCKETS
            NumberChart
          else
            opts[:buckets] = BUCKETS
            RangeChart
          end
        chart_class.new format, opts
      end
    end
  end
end
