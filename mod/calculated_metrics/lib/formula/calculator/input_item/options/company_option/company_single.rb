module Formula
  class Calculator
    class InputItem
      module Options
        module CompanyOption
          # Used if a single company is passed as company option.
          # It makes the values for this input item independent of the output company
          # (since the answer for company of the company option is always used)
          # Example:
          #   {{ M1 | company: Death Star }}
          module CompanySingle
            extend AddValidationChecks
            include CompanyIndependentInput

            add_validation_checks :check_company_option

            def check_company_option
              if !object_company_id
                add_error "unknown card: #{company_option}"
              elsif Card.fetch_type_id(object_company_id) != Card::WikirateCompanyID
                add_error "not a company: #{company_option}"
              end
            end

            def each_answer
              answers.each do |a|
                value = Answer.value_from_lookup a.value, type
                yield nil, a.year, value
              end
            end

            def values_by_year_for_each_company
              y_and_v = Answer.where(metric_id: card_id, company_id: object_company_id)
                              .pluck(:year, :value)
              yield nil, y_and_v.to_h
            end

            private

            def object_company_id
              Card.fetch_id company_option
            end

            def answer_query
              query = super
              query[:company_id] = object_company_id
              query
            end
          end
        end
      end
    end
  end
end
