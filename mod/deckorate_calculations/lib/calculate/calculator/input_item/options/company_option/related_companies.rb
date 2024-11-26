class Calculate
  class Calculator
    class InputItem
      module Options
        module CompanyOption
          # Used if a relationship metric (or inverse relationship metric) is
          # passed as company option.
          module RelatedCompanies
            # answers can be calculated for any company/year for which there exists
            # an answer to a company related by the relationship metric.

            # @return Hash
            # keys are company ids, values are Hashes, each of which has
            # year as a key and InputAnswer object as a value
            def input_answers_by_company_and_year
              object_answers = super
              # answers for object companies (same hash representation as result)

              relationship_hash.each_with_object({}) do |(subject_id, object_id_list), h|
                obj_answers = object_id_list.map { |id| object_answers[id] }.compact
                next unless obj_answers.present?
                h[subject_id] = consolidate_object_answers obj_answers
              end
            end

            # must be overwritten, because "answers" does not filter by company
            def answers_for company_id, year
              @search_space = SearchSpace.new company_id, year
              ::Answer.where answer_query.merge(company_id: relationship_hash[company_id])
            end

            private

            # do not restrict the object answer query based on the company_id restriction,
            # which is intended for the answer's subject company
            def answer_query
              super.tap { |h| h.delete :company_id }
            end

            # the card for the metric specified in the country option
            def relationship_metric
              @relationship_metric ||= company_option_card
            end

            # @return [Hash] keys are subject company ids,
            #   values are lists of object company ids
            #
            # NOTE: regardless of the year of the resultant answer, the relationships
            #   are always based on the latest year
            def relationship_hash
              args = { latest: true }
              args[:company] = search_space.company_ids if search_space.company_ids?
              relationship_metric.related_companies_hash args
            end

            # for each list of
            # @return [Hash] keys are years, values are consolidated InputAnswer objects
            #   that represent answers for object companies
            def consolidate_object_answers obj_answers
              consolidate_object_hash(obj_answers).tap do |hash|
                hash.each do |year, answer_list|
                  hash[year] = consolidated_input_answer answer_list, year
                end
              end
            end

            # consolidates a list of object hashes (for each hash, keys are years and
            # values are InputAnswer objects) to a subject hash
            #
            # @return [Hash] keys are years, values are arrays of InputAnswer objects
            def consolidate_object_hash obj_answers
              obj_answers.each_with_object({}) do |obj_hash, subj_hash|
                obj_hash.each do |year, answer|
                  subj_hash[year] ||= []
                  subj_hash[year] << answer
                end
              end
            end
          end
        end
      end
    end
  end
end
