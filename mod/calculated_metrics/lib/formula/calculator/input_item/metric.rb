module Formula
  class Calculator
    class InputItem
      class Metric < InputItem
        def initialize input_list, input_index
          super
          extend AllRequired if all_input_required?
          extend YearOption if year_option?
          extend CompanyOption if company_option?
        end

        def type
          @input_type ||= @input_card.value_type_code
        end

        # Find answer for the given input card and cache the result.
        # If year is given look only for that year
        def fetch_value year
          answers = answers year

          company_list.update answers.map(&:company_id)
          answers.each do |a|
            value = Answer.value_from_lookup a.value, input_item.type
            store_value input_item, a.company_id, a.year, value
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
