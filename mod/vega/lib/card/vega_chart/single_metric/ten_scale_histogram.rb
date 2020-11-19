class Card
  class VegaChart
    class SingleMetric
      # chart for scores and wikiratings with one bucket for each integer between 0 and 10
      # (eg 0-0.999 is one bucket.  10 has its own bucket)
      class TenScaleHistogram < Histogram

      end
    end
  end
end
