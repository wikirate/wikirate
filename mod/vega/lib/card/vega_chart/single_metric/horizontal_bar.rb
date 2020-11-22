class Card
  class VegaChart
    class SingleMetric
      # horizontal bar chart.  y axis is individual companies, x axis is numeric answer
      # value
      class HorizontalBar < SingleMetric
        include Axes
        include AnswerValues

        def hash
          with_answer_values 1 do
            with_company_values { super }
          end
        end

        def with_company_values index=0
          yield.tap do |data_hash|
            data_hash[:data][index].merge! company_values
          end
        end

        def company_values
          { values: format.render(:compact_companies) }
        end

        def layout
          super.merge builtin(:horizontal_bar)
        end

        def x_axis
          super.merge title: value_title, format: "~s" # number formatting
        end

        def y_axis
          super.merge labelColor: "#666", labelFontWeight: 600
        end
      end
    end
  end
end
