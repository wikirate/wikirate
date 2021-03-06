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
          encode = hash[:marks].first[:encode]
          encode[:update][:fill] = highlight_fill
          encode[:hover][:cursor] = "default"
        end

        def highlight_data hash
          dataset = hash[:data].last
          dataset[:transform] ||= []
          dataset[:transform] << highlight_transform
        end
      end
    end
  end
end
