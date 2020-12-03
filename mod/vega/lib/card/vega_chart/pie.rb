class Card
  class VegaChart
    # Timeline of answer values
    class Pie < VegaChart
      def hash
        with_values(year_list: 1) { super }
      end

      def layout
        super.merge builtin(:pie)
      end
    end
  end
end
