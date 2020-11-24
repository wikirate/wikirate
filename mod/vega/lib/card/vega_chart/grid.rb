class Card
  class VegaChart
    # Grid of answer values
    class Grid < VegaChart
      def hash
        with_values(company_list: 0, metric_list: 1, answer_list: 2) do
          super.tap do |h|
            h[:scales] << builtin(:ten_scale_color)
          end
        end
      end

      def layout
        super.merge builtin(:grid)
      end
    end
  end
end
