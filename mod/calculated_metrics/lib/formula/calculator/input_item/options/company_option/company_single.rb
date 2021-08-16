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
              if !requested_company_id
                add_error "unknown card: #{company_option}"
              elsif Card.fetch_type_id(requested_company_id) != Card::WikirateCompanyID
                add_error "not a company: #{company_option}"
              end
            end

            def year_value_pairs
              Answer.where(metric_id: card_id, company_id: requested_company_id)
                    .pluck(:year, :value).to_h
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
