class Card
  class VegaChart
    class SingleMetric
      # horizontal bar chart.  y axis is individual companies, x axis is numeric answer
      # value
      class HorizontalBar < SingleMetric
        include Axes
        include AnswerValues


      end
    end
  end
end
