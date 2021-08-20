module Formula
  class Calculator
    class InputItem
      # Uses the answer table to find values.
      module MetricInputItem
        include CompanyDependentInput

        def type
          @type ||= @input_card.simple_value_type_code
        end

        # Searches for all metric answers for this metric input.
        def answers
          Answer.where answer_query
        end

        private

        def year_value_pairs_by_company
          answers.pluck(:company_id, :year, :value)
                 .each_with_object({}) do |(c, y, v), h|
            h[c] ||= {}
            h[c][y] = v
          end
        end

        def store_value company_id, year, value
          super company_id, year, Answer.value_from_lookup(value, type)
        end

        # used for CompanyOption
        def values_from_db company_ids, year
          Answer.where(metric_id: card_id, company_id: company_ids, year: year.to_i)
                .pluck(:value).map do |v|
            Answer.value_from_lookup v, type
          end
        end

        # used for CompanyOption
        def years_from_db company_ids
          Answer.select(:year).where(metric_id: card_id, company_id: company_ids)
                .distinct.pluck(:year)
        end

        def search_company_ids
          Answer.select(:company_id).where(metric_id: card_id).distinct.pluck(:company_id)
        end

        def answer_query
          query = { metric_id: card_id }
          query[:year] = search_space.years if restrict_years_in_query?
          query[:company_id] = search_space.company_ids if search_space.company_ids?
          query
        end

        def restrict_years_in_query?
          search_space.years?
        end
      end
    end
  end
end
