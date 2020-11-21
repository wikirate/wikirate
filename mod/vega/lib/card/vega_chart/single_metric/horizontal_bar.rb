class Card
  class VegaChart
    class SingleMetric
      # horizontal bar chart.  y axis is individual companies, x axis is numeric answer
      # value
      class HorizontalBar < SingleMetric
        include Axes
        include AnswerValues

        def layout
          super.merge builtin(:horizontal_bar)
        end

        def x_axis
          super.merge title: value_title, format: "~s" # number formatting
        end

        def y_axis
          super.merge labelColor: "#666", labelFontWeight: 600
        end
      end
    end
  end
end
