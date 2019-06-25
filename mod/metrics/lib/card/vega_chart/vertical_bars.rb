class Card
  class VegaChart
    class VerticalBars < VegaChart
      def x_axis
        { orient: "bottom", scale: "x", title: "Values",
          encode: diagonalize(axes_encode) }
      end

      def y_axis
        hash = { orient: "left", scale: "y",
                 title: @format.rate_subjects,
                 encode: axes_encode }
        hash[:tickCount] = y_tick_count if y_tick_count
        hash
      end
    end
  end
end
