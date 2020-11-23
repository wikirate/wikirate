class Card
  class VegaChart
    module Helper
      # Vega visualizations for single metrics
      module SingleMetric
        def metric_card
          @metric_card ||= format.metric_card
        end
      end
    end
  end
end
