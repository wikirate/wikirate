class Card
  class VegaChart
    # Timeline of record values
    class Timeline < VegaChart
      include Helper::Axes
      include Helper::CountTips
      include Helper::Exponent
      include Helper::Subgroup

      def layout
        super.merge builtin(:timeline)
      end

      def x_axis
        super.tap do |h|
          h[:offset] = 10
          h[:encode][:labels][:update].merge!(
            fontWeight: [{ test: "datum.value == tooltip.year", value: 900 },
                         { "value": 400 }],
            fill: [{ test: "datum.value == tooltip.year", value: "#000" },
                   { value: "#888" }]
          )
        end
      end

      def filter_data_index
        -2
      end

      def y_axis
        super.merge count_axis
      end
    end
  end
end
