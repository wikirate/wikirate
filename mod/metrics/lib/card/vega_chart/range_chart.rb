class Card
  class VegaChart
    # Company count histograms.  Each vertical bar represents a range of values
    class RangeChart < VerticalBars
      include Buckets

      DEFAULT_BAR_CNT = 10

      def initialize format, opts
        opts[:highlight] &&= opts[:highlight].to_f
        @buckets ||= opts.delete(:buckets) || DEFAULT_BAR_CNT
        super format, opts
      end

      def generate_data
        add_label min
        each_bucket do |lower, upper, last|
          add_data lower, count_in_range(lower, upper, last), from: lower, to: upper
          add_label upper
        end
      end

      def count_in_range lower, upper, last
        tally = 0
        op = last ? "<=" : "<"
        raw_counts.each_key do |val|
          tally += tally_increment(val) if val_between? lower, upper, val, op
        end
        tally
      end

      def raw_counts
        @raw_counts ||= @filter_query.count_by_group(:numeric_value).reject { |k| k.nil? }
      end

      private

      def tally_increment val
        raw_counts.delete(val).to_i
      end

      def val_between? lower, upper, val, op
        val >= lower && val.send(op, upper)
      end

      def data_item_hash filter, _count
        super.merge xfield: filter[:numeric_value][:to]
      end

      def x_axis
        super.merge scale: "x_label", format: "~s", title: title_with_unit("Ranges")
      end

      def scales
        super << x_label_scale
      end

      def x_label_scale
        { name: "x_label", type: "point", range: "width", domain: @labels }
      end

      def highlight? value
        return true unless @highlight_value
        @highlight_value >= value[:from] && @highlight_value < value[:to]
      end
    end
  end
end
