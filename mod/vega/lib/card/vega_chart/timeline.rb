class Card
  class VegaChart
    # Timeline of answer values
    class Timeline < VegaChart
      include Helper::Axes

      def hash
        with_values(year_list: 0) { super }
      end

      def layout
        super.merge builtin(:timeline)
      end

      def x_axis
        super.merge offset: 8
      end

      def y_axis
        super.merge tickMinStep: 1
      end
    end
  end
end
