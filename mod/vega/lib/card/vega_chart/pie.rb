class Card
  class VegaChart
    # Timeline of answer values
    class Pie < VegaChart
      include Helper::Subgroup

      def layout
        super.merge builtin(:pie)
      end
    end
  end
end
