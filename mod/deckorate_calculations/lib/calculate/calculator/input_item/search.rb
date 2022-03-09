class Calculate
  class Calculator
    class InputItem
      # private methods for finding relevant input answers
      module Search
        def search result_space=nil
          @result_space = result_space || ResultSpace.new(false)
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

        def each_input_answer rel, object
          rel.pluck(*INPUT_ANSWER_FIELDS).each_with_object(object) do |fields, obj|
            company_id = fields.shift
            year = fields.shift
            input_answer = InputAnswer.new self, company_id, year
            input_answer.assign(*fields)
            yield input_answer, obj
          end
        end

        def search_company_ids
          Answer.select(:company_id).distinct
                .where(metric_id: input_card.id).pluck(:company_id)
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

        def consolidated_input_answer input_answers, year
          value = input_answers.map(&:value)
          unpublished = input_answers.find(&:unpublished)
          verification = input_answers.map(&:verification).compact.min || 1
          InputAnswer.new(self, nil, year).assign value, unpublished, verification
        end
      end
    end
  end
end
