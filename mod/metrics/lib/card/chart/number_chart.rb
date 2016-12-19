class Card
  module Chart
    # generates chart with one bar per (numeric)value
    class NumberChart < CategoryChart
      def generate_data
        @filter_query.where.order(:value).each do |ma|
          add_data numeric_value: ma.numeric_value
        end
      end

      private

      def data_item_hash filter
        super.merge x: filter[:numeric_value]
      end

      def x_axis
        super.merge title: "Values"
      end
    end
  end
end
