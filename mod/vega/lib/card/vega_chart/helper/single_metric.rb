class Card
  class VegaChart
    module Helper
      # Vega visualizations for single metrics
      module SingleMetric
        def metric_card
          @metric_card ||= format.metric_card
        end

        def count_axis
          { title: "# #{count_unit}", tickMinStep: 1 }
        end

        def count_unit
          multiyear? ? "Answers" : "Companies"
        end
      end
    end
  end
end
