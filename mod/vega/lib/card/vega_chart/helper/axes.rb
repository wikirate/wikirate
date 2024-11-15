class Card
  class VegaChart
    module Helper
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

        def count_axis
          { title: "# #{count_unit}", tickMinStep: 1 }
        end

        def count_unit
          multiyear? ? "Records" : "Companies"
        end
      end
    end
  end
end
