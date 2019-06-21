class Card
  module Chart
    class RangeChart < VegaChart
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
          add_data({ numeric_value: { from: lower, to: upper } },
                   count_in_range(lower, upper))
          add_label upper
        end
      end

      def count_in_range lower, upper
        raw_counts.keys.inject do |tally, val|
          next unless val >= lower && val < upper

          tally += raw_counts.delete(val)
        end
      end

      def raw_counts
        @raw_counts ||= @filter_query.count_by_group(:numeric_value).reject(&:nil?)
      end

      private

      def click_action
        :zoom
      end

      def add_label number
        @labels << @format.number_to_human(number.to_f)
      end

      def data_item_hash filter, _count
        super.merge x: filter[:numeric_value][:to]
      end

      def x_axis
        super.merge scale: "x_label", title: "Ranges"
      end

      def scales
        super << x_label_scale
      end

      def x_label_scale
        { name: "x_label",
          type: "point",
          range: "width",
          domain: @labels }
      end

      def highlight? filter
        return true unless @highlight_value
        from = filter[:value][:from]
        to = filter[:value][:to]
        @highlight_value >= from && @highlight_value < to
      end

      def highlight_value_from_filter_opts _filter_opts
        nil # zoom instead of higlight
        # filter_opts[:range][:from]
      end
    end
  end
end
