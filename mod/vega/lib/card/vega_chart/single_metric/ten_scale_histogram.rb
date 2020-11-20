class Card
  class VegaChart
    class SingleMetric
      # chart for scores and wikiratings with one bucket for each integer between 0 and 10
      # (eg 0-0.999 is one bucket.  10 has its own bucket)
      class TenScaleHistogram < Histogram
        def to_hash
          super.tap do |hash|
            hash[:scales].first[:domain] = [0, 10]
            hash[:marks].first[:encode][:update][:fill] =
                { scale: "scoreColor", field: "floor" }
          end
        end

        def data
          super.tap do |hash|
            hash[:data].last[:transform] <<
              { type: "formula", expr: "floor(datum.bin0)", as: "floor" }
          end
        end

        def extent
          [0, 10]
        end

        def x_title
          "Score"
        end
      end
    end
  end
end
