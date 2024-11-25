class Card
  class VegaChart
    # horizontal bar chart.  y axis is individual companies, x axis is numeric answer
    # value
    class HorizontalBar < VegaChart
      include Helper::SingleMetric
      include Helper::Axes
      include Helper::Exponent

      def hash
        with_values(company_list: 0, keyed_answer_list: 1) { super }
      end

      def layout
        super.merge builtin(:horizontal_bar)
      end

      def x_axis
        super.merge title: value_title, format: ",~r" # number formatting
      end

      def y_axis
        super.merge labelColor: "#666", labelFontWeight: 600
      end
    end
  end
end
