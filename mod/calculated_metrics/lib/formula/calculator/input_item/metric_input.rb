module Formula
  class Calculator
    class InputItem
      class MetricInput < InputItem
        def type
          @input_type ||= @input_card.value_type_code
        end

        # Find answer for the given input card and cache the result.
        # If year is given look only for that year
        def search_value year
          answers = answers year

          company_list.update answers.map(&:company_id)
          answers.each do |a|
            value = Answer.value_from_lookup a.value, type
            store_value a.company_id, a.year, value
          end
        end

        private

        # Searches for all metric answers for this metric input.
        # If a year is given then the search will be restricted to that year
        # @param year
        def answers year
          Answer.where answer_query(year)
        end

        def answer_query year
          query = { metric_id: card_id }
          query[:year] = year.to_i if year
          query
        end
      end
    end
  end
end
