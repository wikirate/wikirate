class Calculate
  class Calculator
    class InputItem
      # private methods for finding relevant input answers
      module Search
        def search result_space=nil
          @result_space = result_space || ResultSpace.new(false)
          @result_slice = ResultSlice.new
          full_search do |company_id, year, input_answer|
            store_value company_id, year, input_answer
          end
          after_search
        end

        # Find answer for the given input card and cache the result.
        # If year is given look only for that year
        def full_search
          input_answers_by_company_and_year.each do |company_id, input_answer_hash|
            each_applicable_year(input_answer_hash.keys) do |year|
              yield company_id, year, apply_year_option(input_answer_hash, year)
            end
          end
        end

        def each_applicable_year raw_years, &block
          years = translate_years raw_years
          if search_space.years.present? && !restrict_years_in_query?
            years = years.intersection search_space.years
          end
          years.each(&block)
        end

        def search_space
          @search_space ||= result_space.answer_candidates
        end

        def after_search
          result_space.update @result_slice, mandatory?
        end

        # Searches for all answers for this metric input.
        def answers
          ::Answer.where answer_query
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
          ::Answer.select(:company_id).distinct
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

        def consolidated_input_answer answers, year
          lookup_ids = consolidate_lookup_ids answers
          value = answers.map(&:value)
          unpublished = answers.find(&:unpublished)
          verification = answers.map(&:verification).compact.min || 1
          InputAnswer.new(self, nil, year)
                     .assign lookup_ids, value, unpublished, verification
        end

        def consolidate_lookup_ids answers
          answers.map { |a| a.try(:lookup_ids) || a.id }.flatten.uniq
        end
      end
    end
  end
end
