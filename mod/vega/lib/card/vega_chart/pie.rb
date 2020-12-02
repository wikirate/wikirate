class Card
  class VegaChart
    # Timeline of answer values
    class Pie < VegaChart
      include Helper::Axes

      def hash
        with_values(year_list: 1) { super }
      end

      def layout
        super.merge builtin(:pie)
      end

      def x_axis
        super.tap do |h|
          h[:offset] = 9
          h[:encode][:labels][:update].merge!(
            fontWeight: [{ test: "datum.value == tooltip.year", value: 900 },
                         { "value": 400 }],
            fill: [{ test: "datum.value == tooltip.year", value:"#000" },
                   { value: "#888" }]
          )
        end
      end

      def y_axis
        super.merge tickMinStep: 1
      end
    end
  end
end
