class Card
  class VegaChart
    # horizontal bar chart.  y axis is individual companies, x axis is numeric answer
    # value
    class HorizontalNumberChart < VegaChart
      def generate_data
        @filter_query.run.each do |answer_card|
          add_data answer_card.company, answer_card.value
        end
      end

      def add_data company, value
        @data << { company: Card.fetch_name(company), answer_val: value }
      end

      def x_scale
        { name: "xscale",
          type: "linear",
          domain: { data: "table", field: "answer_val" },
          nice: true,
          range: "width" }
      end

      def y_scale
        { name: "yscale",
          type: "band",
          domain: { data: "table", field: "company" },
          range: "height",
          padding: 0.05,
          round: true }
      end

      def x_axis
        { orient: "bottom", scale: "xscale" }
      end

      def y_axis
        { orient: "left", scale: "yscale" }
      end

      def main_mark
        builtin :horizontal_mark
      end
    end
  end
end
