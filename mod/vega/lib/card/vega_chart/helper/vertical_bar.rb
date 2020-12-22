class Card
  class VegaChart
    module Helper
      # shared by histograms and bar graphs
      module VerticalBar
        include SingleMetric
        include Axes
        include Highlight
        include CountTips

        def y_axis
          super.merge count_axis
        end

        def hash
          super.tap do |h|
            h[:data] << builtin(:count_extremes)
            h[:signals] += builtin(:dynamic_exponent)[:signals]
          end
        end
      end
    end
  end
end
