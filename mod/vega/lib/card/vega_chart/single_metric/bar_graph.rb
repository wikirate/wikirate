class Card
  class VegaChart
    class SingleMetric
      # chart for categorical metrics
      # shows companies per category
      class BarGraph < SingleMetric
        include Axes
        include AnswerValues

        def to_hash
          layout.merge data
        end

        private

        def data
          with_answer_values { builtin :bar_graph_data }
        end

        def layout
          super.merge builtin(:bar_graph)
        end

        def x_axis
          super.merge title: "Category"
        end

        def y_axis
          super.merge count_axis
        end


        # @return true if the bar given by its filter
        #   is supposed to be highlighted
        def highlight? value
          return true unless @highlight_value

          @highlight_value == value
        end
      end
    end
  end
end
