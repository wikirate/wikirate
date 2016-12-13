class Card
  module Chart
    class NumericChart < VegaChart
      BUCKETS = 10

      def initialize format, opts
        opts[:highlight] &&= opts[:highlight].to_f
        super format, opts
      end

      def generate_data
        calculate_ranges
        add_label min
        each_bucket do |lower, upper|
          add_data range: { from: lower, to: upper }
          add_label upper
        end
      end

      private

      def each_bucket
        lower = min
        BUCKETS.times do
          upper = lower + bucket_size
          yield lower, upper
          lower = upper
        end
      end

      def add_label number
        @labels << { text: @format.number_to_human(number.to_f).to_f }
      end

      def data_item_hash filter
        super(filter).merge x: filter[:range][:to]
      end

      def data
        super << { name: "x_labels", values: @labels }
      end

      def x_axis
        super.merge scale: "x_label", title: "Ranges"
      end

      def scales
        super << x_label_scale
      end

      def x_label_scale
        { name: "x_label",
          type: "ordinal",
          range: "width",
          domain: { data: "x_labels", field: "text", sort: true },
          points: true }
      end

      def calculate_ranges
        if bucket_size > 2
          @bucket_size = (@bucket_size + 1).to_i
          @min = @min.to_i
          @max = @min + @bucket_size * BUCKETS
        end
      end

      def bucket_size
        @bucket_size ||= (max - min).to_f / BUCKETS
      end

      def max
        @max ||= @filter_query.where.maximum(:numeric_value).to_f
      end

      def min
        @min ||= @filter_query.where.minimum(:numeric_value).to_f
      end

      def highlight? filter
        return true unless @highlight_value
        from, to = filter[:range][:from], filter[:range][:to]
        @highlight_value >= from && @highlight_value < to
      end

      def highlight_value_from_filter_opts filter_opts
        filter_opts[:range][:from]
      end
    end
  end
end
