class Card
  class VegaChart
    # support for adding answer data to vega charts
    module AnswerValues
      def answer_values view
        { values: format.render(view) }
      end

      def with_answer_values index: 0, view: :compact_answers
        yield.tap do |data_hash|
          data_hash[:data][index].merge! answer_values(view)
        end
      end

      def count_axis
        { title: "# #{count_unit}", tickMinStep: 1 }
      end

      def count_unit
        multiyear? ? "Companies" : "Answers"
      end
    end
  end
end
