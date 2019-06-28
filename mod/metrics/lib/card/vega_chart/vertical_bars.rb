class Card
  class VegaChart
    # Vertical bar charts where the x axis is answer values and the
    # y axis is company counts
    class VerticalBars < VegaChart
      Range = Struct.new(:min, :max) do
        def add value
          self.min = [min, value].compact.min
          self.max = [max, value].compact.max
        end

        def span
          return 0 unless max && min
          max - min
        end
      end

      def add_data xval, yval, filter=nil
        @data << { xfield: xval,
                   yfield: yval,
                   filter: { value: (filter || xval) },
                   highlight: highlight?(filter || xval) }
        y_range.add yval
        @data
      end

      def main_mark
        builtin :vertical_mark
      end

      def x_scale
        super.merge type: "band", padding: 0.1
      end

      def y_scale
        super.merge type: y_type, round: true
      end

      def y_range
        @y_range ||= Range.new
      end

      def y_type
        y_range.span > 100 ? "sqrt" : "linear"
      end

      def y_axis
        hash = super.merge title: y_title
        hash[:tickCount] = y_tick_count if y_tick_count
        hash
      end

      def y_title
        @filter_query.filter_args[:year] ? @format.rate_subjects : "Answers"
      end

      def marks
        super << builtin(:tooltip_mark)
      end

      # If the maximal value is less than 8 then vega shows
      # non-integers labels. We have to reduce the number of ticks
      # to the maximal value to avoid that
      # @max_ticks is a config option
      def y_tick_count
        return max_ticks if y_range.max && y_range.max >= 8
        [y_range.max, max_ticks].compact.min
      end

      def max_ticks
        @max_ticks ||= @layout.delete(:max_ticks)
      end
    end
  end
end
