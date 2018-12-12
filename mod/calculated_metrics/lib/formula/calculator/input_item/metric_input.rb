module Formula
  class Calculator
    class InputItem
      # Instances of {MetricInput} represent input items that refer to a metric
      # It uses the answer table to find values.
      class MetricInput < InputItem
        include CompanyDependentInput
        def type
          @input_type ||= @input_card.value_type_code
        end

        private

        def each_answer
          answers.each do |a|
            value = Answer.value_from_lookup a.value, type
            yield a.company_id, a.year, value
          end
        end

        # used by YearOption to find values
        # Other options like CompanyOption adapt it so that
        # they work together with year options
        def values_by_year_for_each_company
          search_company_ids.each do |c_id|
            #years, values = search_years_and_values(c_id).transpose
            values_by_year =
              search_years_and_values(c_id).each_with_object({}) do |(y, v), h|
                h[y] = v
              end
            yield c_id, values_by_year
          end
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

        # used only by YearOption; overwritten by CompanyOption
        def search_years_and_values company_id
          Answer.where(metric_id: card_id, company_id: company_id).pluck(:year, :value)
        end

        # Searches for all metric answers for this metric input.
        # If a year is given then the search will be restricted to that year
        # @param year
        def answers
          Answer.where answer_query
        end

        def answer_query
          query = { metric_id: card_id }
          query[:year] = search_space.years if search_space.years?
          query[:company_id] = search_space.company_ids if search_space.company_ids?
          query
        end
      end
    end
  end
end
