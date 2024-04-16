class Calculate
  class Calculator
    class InputItem
      module Options
        module CompanyOption
          # Used if a single company is passed as company option.
          # It makes the values for this input item independent of the output company
          # (since the answer for company of the company option is always used)
          module SingleCompany
            include CompanyIndependentInput

            def year_answer_pairs
              each_input_answer answers, {} do |input_answer, hash|
                hash[input_answer.year] = input_answer
              end
            end

            def restrict_companies query
              query[:company_id] = requested_company_id
            end

            private

            def requested_company_id
              @requested_company_id ||= company_option.card_id
            end
          end
        end
      end
    end
  end
end
