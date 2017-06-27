class Card
  module Chart
    # chart for score metrics with one bucket for each integer between 0 and 10
    class ScoreChart < RangeChart
      DEFAULT_BAR_CNT = 11

      def calculate_buckets
        @min = 0
        @max = 11
        @bucket_size = 1
        @buckets = 11
        @use_log_scale = false
      end

      def generate_data
        calculate_buckets
        each_bucket do |lower, upper|
          add_data range: { from: lower, to: upper }
          add_label lower
        end
      end

      # def generate_data
      #    # @filter_query.where.order(:value).each do |ma|
      #    #   add_data numeric_value: ma.numeric_value.to_i if ma.numeric_value
      #    # end
      #    0.upto(10).each do |i|
      #      add_data numeric_value: i
      #    end
      #  end

      def x_axis
        super.merge title: "Scores"
      end

      def x_label_scale
        super().merge(type: "band")
      end
    end
  end
end
