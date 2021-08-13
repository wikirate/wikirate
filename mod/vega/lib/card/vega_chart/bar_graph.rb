class Card
  class VegaChart
    # chart for categorical metrics shows companies per category
    class BarGraph < VegaChart
      include Helper::VerticalBar

      def hash
        with_values(answer_list: 0) do
          super.tap do |h|
            transform_multi_values h[:data]
            insert_value_options_map h[:data]
            lookup_option_labels h[:data]
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

      def insert_value_options_map data
        data.insert 1, {
          name: "options",
          url: value_options_url
        }
      end

      def value_options_url
        metric_card.value_options_card.format.path view: :option_list, format: :json
      end

      def lookup_option_labels data
        # this is rawCounts
        # TODO: lookup dataset by name
        # don't rely on index staying the same!
        # should add support library
        data[2][:transform] << {
          type: "lookup",
          from: "options",
          key: "key",
          fields: ["value"],
          as: ["label"],
          values: ["name"]
        }
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
