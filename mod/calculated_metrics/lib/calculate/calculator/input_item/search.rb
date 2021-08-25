class Calculate
  class Calculator
    class InputItem
      # private methods for finding relevant input answers
      module Search
        def search result_space
          @result_space = result_space
          @result_slice = ResultSlice.new
          full_search
          after_search
        end

        # Find answer for the given input card and cache the result.
        # If year is given look only for that year
        def full_search
          year_value_pairs_by_company.each do |company_id, year_value_hash|
            translate_years(year_value_hash.keys).each do |year|
              store_value company_id, year, apply_year_option(year_value_hash, year)
            end
          end
        end

        def search_space
          @search_space ||= result_space.answer_candidates
        end

        def after_search
          result_space.update @result_slice, mandatory?
        end

        # Searches for all metric answers for this metric input.
        def answers
          Answer.where answer_query
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
            each_input_answer sub_answers_rel(company_ids, year) do |input_answer|
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

        def value_store
          @value_store ||= value_store_class.new
        end

        def store_value company_id, year, value
          value_store.add company_id, year, value
          update_result_slice company_id, year, value
        end

        def with_restricted_search_space company_id, year
          @search_space = SearchSpace.new company_id, year
          @search_space.intersect! result_space.answer_candidates
          yield
        ensure
          @search_space = nil
        end
      end
    end
  end
end
