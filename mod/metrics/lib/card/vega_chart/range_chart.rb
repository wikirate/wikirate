class Card
  class VegaChart
    # Company count histograms.  Each vertical bar represents a range of values
    class RangeChart < VerticalBars
      include Buckets

      DEFAULT_BAR_CNT = 10

      def initialize format, opts
        opts[:highlight] &&= opts[:highlight].to_f
        @buckets = opts.delete(:buckets) || DEFAULT_BAR_CNT
        super format, opts
      end

      def generate_data
        calculate_buckets
        add_label min
        each_bucket do |lower, upper|
          add_data lower, count_in_range(lower, upper), from: lower, to: upper
          add_label upper
        end
      end

      def count_in_range lower, upper
        tally = 0
        raw_counts.each_key do |val|
          next unless val >= lower && val < upper
          tally += raw_counts.delete(val).to_i
        end
        tally
      end

      def raw_counts
        @raw_counts ||= @filter_query.count_by_group(:numeric_value).reject { |k| k.nil? }
      end

      private

      def data_item_hash filter, _count
        super.merge xfield: filter[:numeric_value][:to]
      end

      def x_axis
        # super.merge scale: "x_label", title: title_with_unit("Ranges")
        super.merge format: "~s", title: title_with_unit("Ranges")
      end

      # def scales
      #   super << x_label_scale
      # end
      #
      # def x_label_scale
      #   { name: "x_label", type: "point", range: "width", domain: x_labels }
      # end
      #
      # def x_labels
      #   precision = 3
      #   while precision < 10
      #     human = @labels.map do |num|
      #       @format.number_to_human num.to_f, precision: precision
      #     end
      #
      #     return human if human.uniq.size == human.size
      #     precision += 1
      #   end
      # end

      def highlight? value
        return true unless @highlight_value
        @highlight_value >= value[:from] && @highlight_value < value[:to]
      end
    end
  end
end
