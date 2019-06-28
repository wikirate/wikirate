class Card
  class VegaChart
    # horizontal bar chart.  y axis is individual companies, x axis is numeric answer
    # value
    class HorizontalNumberChart < VegaChart
      def generate_data
        @filter_query.run.each do |answer|
          next unless (value = answer.value) && @format.card.number?(value)
          add_data answer, value
        end
      end

      def add_data answer, value
        @data << { yfield: ylabel(answer), xfield: value, details: answer.name.url_key }
      end

      def ylabel answer
        return answer.year if record?

        company = Card.fetch_name(answer.company).to_s
        if multiyear?
          "#{company.truncate 15} (#{answer.year})"
        else
          company.truncate 20
        end
      end

      def multiyear?
        !@filter_query.filter_args[:year]
      end

      def record?
        @format.try :record?
      end

      def x_axis
        super.merge format: "~s" # number formatting
      end

      def x_scale
        super.merge type: "linear", nice: true
      end

      def y_scale
        super.merge type: "band", padding: 0.05
      end

      def main_mark
        builtin :horizontal_mark
      end
    end
  end
end
