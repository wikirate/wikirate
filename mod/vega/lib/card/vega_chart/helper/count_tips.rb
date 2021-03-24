class Card
  class VegaChart
    module Helper
      # default count tip configuration for vega charts
      module CountTips
        def hash
          super.tap do |h|
            h[:signals] << builtin(:tooltip_signal)
          end
        end
      end
    end
  end
end
