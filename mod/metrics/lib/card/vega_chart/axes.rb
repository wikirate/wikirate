class Card
  class VegaChart
    # default axis configuration for vega charts
    module Axes
      def x_axis
        diagonalize orient: "bottom", scale: "xscale"
      end

      def y_axis
        { orient: "left", scale: "yscale" }
      end

      def diagonal_x_labels?
        true
      end

      def diagonalize x_axis
        return unless diagonal_x_labels?

        x_axis.deep_merge! encode: { labels: { update: { angle: { value: 30 },
                                                         limit: { value: 70 },
                                                         align: { value: "left" } } } }
      end

      def title_with_unit title
        return title unless (unit = metric_card.unit) && unit.present?

        "#{title} (#{unit})"
      end
    end
  end
end
