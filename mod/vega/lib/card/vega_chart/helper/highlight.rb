class Card
  class VegaChart
    module Helper
      # default highlight configuration for vega charts
      module Highlight
        def highlight?
          @highlight_value.present?
        end

        def hash
          return super unless highlight?
          super.tap do |hash|
            hash[:signals] << highlight_signal
            hash[:scales] << highlight_scale
            highlight_marks hash
            highlight_data hash
          end
        end

        def highlight_signal
          { name: "highlight", value: @highlight_value }
        end

        def highlight_scale
          builtin :highlight_color
        end

        def highlight_transform
          { type: "formula", as: "highlight", expr: "datum.value == highlight" }
        end

        def highlight_fill
          { scale: "highlightColor", field: "highlight" }
        end

        def highlight_marks hash
          hash[:marks].first[:encode][:update][:fill] = highlight_fill
        end

        def highlight_data hash
          hash[:data].last[:transform] << highlight_transform
        end
      end
    end
  end
end
