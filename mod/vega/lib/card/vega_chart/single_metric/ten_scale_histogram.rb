class Card
  class VegaChart
    class SingleMetric
      # chart for scores and wikiratings with one bucket for each integer between 0 and 10
      # (eg 0-0.999 is one bucket.  10 has its own bucket)
      class TenScaleHistogram < Histogram
        def hash
          super.tap do |hash|
            tenscale_scales hash[:scales]
            tenscale_data hash[:data]
            tenscale_marks hash[:marks]
          end
        end

        def tenscale_scales scales
          scales.first[:domain] = [0, 10]
        end

        def tenscale_marks marks
          return if highlight?
          marks.first[:encode][:update][:fill] = { scale: "scoreColor", field: "floor" }
        end

        def tenscale_data data
          data.last[:transform] <<
            { type: "formula", expr: "floor(datum.bin0)", as: "floor" }
        end

        def extent
          "[0, 10]"
        end

        def x_title
          "Score"
        end
      end
    end
  end
end
