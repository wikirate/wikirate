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

      def add_data filter, count
        @data << data_item_hash(filter, count)
        y_range.add @data.last[:yfield]
        @data
      end

      def data_item_hash filter, count
        { yfield: count, filter: filter, highlight: highlight?(filter) }
      end

      def main_mark
        builtin :vertical_mark
      end

      def x_scale
        super.merge type: "band"
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

      def x_axis
        super.merge title: title_with_unit("Values"),
                    encode: diagonalize(axes_colors)
      end

      def y_axis
        hash = super.merge title: @format.rate_subjects, encode: axes_colors
        hash[:tickCount] = y_tick_count if y_tick_count
        hash
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

      def diagonal_x_labels?
        true
      end

      def diagonalize encode
        return unless diagonal_x_labels?

        encode.deep_merge! labels: { update: { angle: { value: 30 },
                                               limit: { value: 70 },
                                               align: { value: "left" } } }
      end
    end
  end
end
