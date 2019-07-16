class Card
  class VegaChart
    # default axis configuration for vega charts
    module Axes
      def x_axis
        diagonalize orient: "bottom", scale: "xscale", encode: axes_colors,
                    title: title_with_unit("Values")
      end

      def y_axis
        { orient: "left", scale: "yscale", encode: axes_colors }
      end

      def diagonal_x_labels?
        true
      end

      def diagonalize x_axis
        return x_axis unless diagonal_x_labels?

        x_axis.deep_merge! encode: { labels: { update: { angle: { value: 30 },
                                                         limit: { value: 70 },
                                                         align: { value: "left" } } } }
      end

      def title_with_unit title
        unit = metric_card.format(:html).value_legend
        return title unless unit.present?

        "#{title} (#{unit})"
      end
    end
  end
end
