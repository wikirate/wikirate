class Card
  class VegaChart
    # chart for scores and wikiratings with one bucket for each integer between 0 and 10
    # (eg 0-0.999 is one bucket.  10 has its own bucket)
    class TenScaleChart < RangeChart
      DEFAULT_BAR_CNT = 11

      def initialize *args
        @min = 0
        @max = 11
        @bucket_size = 1
        @buckets = 11
        super
        # @use_log_scale = false
      end

      def generate_data
        group_data
        each_bucket do |lower, upper, _last|
          add_data lower, @counts[lower], from: lower, to: upper
          add_label lower # == 10 ? 10 : "#{lower}+"
        end
        add_label ""
      end

      def group_data
        @counts = {}
        @filter_query.count_by_group(:numeric_value).each do |num, count|
          key = num.to_i
          @counts[key] = @counts[key].to_i + count
        end
      end

      def x_axis
        axis = super
        axis[:title] = "Scores"
        axis.delete :format
        axis
      end

      # def x_label_scale
      #   super.merge type: "band"
      # end

      def diagonal_x_labels?
        false
      end
    end
  end
end
