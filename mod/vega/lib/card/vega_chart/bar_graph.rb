class Card
  class VegaChart
    # chart for categorical metrics shows companies per category
    class BarGraph < VegaChart
      include Helper::SingleMetric
      include Helper::Axes
      include Helper::Highlight
      include Helper::CountTips
      include Helper::Exponent

      def hash
        with_values(answer_list: 0) do
          super.tap do |h|
            transform_multi_values h[:data]
          end
        end
      end

      private

      def transform_multi_values data
        return unless metric_card.multi_categorical?

        data.first[:transform] = [
          { type: "formula", expr: "split(datum.value, ', ')", as: "value" },
          { type: "flatten", fields: ["value"] }
        ]
      end

      def layout
        super.merge builtin(:bar_graph)
      end

      def x_axis
        super.merge title: "Category"
      end

      def y_axis
        super.merge count_axis
      end
    end
  end
end
