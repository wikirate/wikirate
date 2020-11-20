class Card
  class VegaChart
    class SingleMetric
      # chart for categorical metrics
      # shows companies per category
      class BarGraph < SingleMetric

        # @return true if the bar given by its filter
        #   is supposed to be highlighted
        def highlight? value
          return true unless @highlight_value

          @highlight_value == value
        end
      end
    end
  end
end
