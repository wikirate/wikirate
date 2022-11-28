class Calculate
  class Calculator
    class InputItem
      module Options
        module CompanyOption
          # Used if a relationship metric (or inverse relationship metric) is
          # passed as company option.
          module RelatedCompanies
            # year => InputAnswer
            def year_value_pairs_by_company
              each_input_answer answers, {} do |input_answer, hash|
                company_hash = hash[input_answer.company_id] ||= {}
                company_hash[input_answer.year] = related_answers input_answer
              end
            end

            def related_answers answer
              consolidated_input_answer answer_list(answer), answer.year
            end

            private

            # year => [Answer]
            def answer_list answer
              rel = related_answer_rel answer
              each_input_answer rel, [] do |input_answer, array|
                array << input_answer
              end
            end

            # used for CompanyOption
            def related_answer_rel answer
              Answer.where metric_id: input_card.id,
                           company_id: inverse_company_ids(answer.company_id),
                           year: answer.year
            end

            def inverse_company_ids company_id
              relationship_metric.inverse_company_ids company: company_id, latest: true
            end

            def relationship_metric
              @relationship_metric ||= company_option_card
            end
          end
        end
      end
    end
  end
end
