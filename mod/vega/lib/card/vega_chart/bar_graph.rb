class Card
  class VegaChart
    # chart for categorical metrics shows companies per category
    class BarGraph < VegaChart
      include Helper::VerticalBar

      def hash
        with_values(answer_list: 0) do
          super.tap do |h|
            transform_multi_values h[:data]
            translate_value_options h[:data]
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

      def translate_value_options data
        data[1][:url] = metric_card.value_options_card.format(:json)
                                   .path view: :option_list, format: :json
      end

      def layout
        super.merge builtin(:bar_graph)
      end

      def x_axis
        super.merge title: "Category"
      end
    end
  end
end
