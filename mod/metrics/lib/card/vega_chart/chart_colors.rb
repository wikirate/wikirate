class Card
  class VegaChart
    # color configuration for vega bar charts
    module ChartColors
      BAR_COLOR = "#eeeeee".freeze
      HIGHLIGHT_COLOR = "#54B2AC".freeze
      HOVER_COLOR = "#03998d".freeze
      DARK_AXES = "#333333".freeze
      LIGHT_AXES = "#cccccc".freeze

      #  used for highlighting
      def color_scale
        {
          name: "color",
          type: "ordinal",
          domain: {
            data: "table",
            field: "highlight",
            sort: true
          },
          range: [BAR_COLOR, HIGHLIGHT_COLOR]
        }
      end

      def fill_color
        if @highlight_value && @data.size > 1
          { scale: "color", field: "highlight" }
        else
          { value: HIGHLIGHT_COLOR }
        end
      end

      def axes_colors
        color = @opts[:axes] == :light ? LIGHT_AXES : DARK_AXES
        { title:  { fill:   { value: color } },
          domain: { stroke: { value: color } },
          ticks:  { stroke: { value: color } },
          labels: { fill:   { value: color } } }
      end
    end
  end
end
