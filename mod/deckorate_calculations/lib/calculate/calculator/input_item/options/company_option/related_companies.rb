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
              consolidated_input_answer answer_list(answer.company_id), answer.year
            end

            private

            # year => [Answer]
            def answer_list company_id
              each_input_answer answer_relation(company_id), [] do |input_answer, array|
                array << input_answer
              end
            end

            # used for CompanyOption
            def answer_relation company_id
              Answer.where metric_id: input_card.id,
                           company_id: inverse_company_ids(company_id)
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
