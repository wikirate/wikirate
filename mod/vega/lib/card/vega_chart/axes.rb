class Card
  class VegaChart
    # default axis configuration for vega charts
    module Axes
      def layout
        super.merge axes: axes
      end

      def axes
        [x_axis, y_axis]
      end

      def x_axis
        builtin :x_axis
      end

      def y_axis
        builtin :y_axis
      end

      def value_title title="Value"
        unit = metric_card.format(:text).render_legend
        return title unless unit.present?

        "#{title} (#{unit})"
      end
    end
  end
end
