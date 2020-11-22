class Card
  class VegaChart
    # support for adding answer data to vega charts
    module AnswerValues
      def answer_values
        { values: format.render(:compact_answers) }
      end

      def with_answer_values index=0
        yield.tap do |data_hash|
          data_hash[:data][index].merge! answer_values
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
