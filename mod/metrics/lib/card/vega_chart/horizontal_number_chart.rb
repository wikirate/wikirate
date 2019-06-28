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
        return @record if @record.present?

        @record = @format.card.try(:record?) || false
      end

      def x_axis
        super.merge format: "~s" # number formatting
      end

      def y_axis
        record? ? super.merge(title: record_company) : super
      end

      def record_company
        Card.fetch_name @filter_query.filter_args[:company_name]
      end

      def x_scale
        super.merge type: "linear", nice: true
      end

      def y_scale
        super.merge type: "band", padding: 0.15
      end

      def main_mark
        builtin :horizontal_mark
      end
    end
  end
end
