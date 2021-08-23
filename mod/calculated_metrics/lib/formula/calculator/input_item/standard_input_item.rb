module Formula
  class Calculator
    class InputItem
      # Uses the answer table to find values.
      class StandardInputItem < InputItem
        include CompanyDependentInput
        
        INPUT_ANSWER_FIELDS = %i[company_id year value unpublished verification]

        def type
          @type ||= @input_card.simple_value_type_code
        end

        # Searches for all metric answers for this metric input.
        def answers
          Answer.where answer_query
        end

        private

        def year_value_pairs_by_company
          {}.tap do |hash|
            each_input_answer answers do |input_answer|
              company_hash = hash[input_answer.company_id] ||= {}
              company_hash[input_answer.year] = input_answer
            end
          end
        end

        def each_input_answer rel
          rel.pluck(*INPUT_ANSWER_FIELDS).each do |fields|
            company_id = fields.shift
            year = fields.shift
            input_answer = InputAnswer.new self, company_id, year
            input_answer.assign(*fields)
            yield input_answer
          end
        end

        # used for CompanyOption
        def combined_input_answers company_ids, year
          sub_input_answers = [].tap do |array|
            each_input_answer sub_answers_rel( company_ids, year) do |input_answer|
              array << input_answer
            end
          end
          consolidated_input_answer sub_input_answers, year
        end

        def sub_answers_rel company_ids, year
          Answer.where metric_id: card_id, company_id: company_ids, year: year
        end

        def consolidated_input_answer input_answers, year
          value = input_answers.map(&:value)
          unpublished = input_answers.find(&:unpublished)
          verification = input_answers.map(&:verification).compact.min || 1
          InputAnswer.new(self, nil, year).assign value, unpublished, verification
        end

        # used for CompanyOption
        def years_from_db company_ids
          Answer.select(:year).distinct
                .where(metric_id: card_id, company_id: company_ids)
                .distinct.pluck(:year).map(&:to_i)
        end

        def search_company_ids
          Answer.select(:company_id).distinct.where(metric_id: card_id).pluck(:company_id)
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
