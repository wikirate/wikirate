class Card
  class VegaChart
    # Grid of answer values
    class Grid < VegaChart
      include Helper::AnswerValues

      def hash
        with_values(company_list: 0, metric_list: 1, answer_list: 2) { super }
      end

      def layout
        super.merge builtin(:grid)
      end
    end
  end
end

