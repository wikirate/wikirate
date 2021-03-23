class Card
  class VegaChart
    module Helper
      # default exponent signal configuration for vega charts
      module Exponent
        def hash
          super.tap do |h|
            h[:signals] << builtin(:exponent_signal)
          end
        end
      end
    end
  end
end
