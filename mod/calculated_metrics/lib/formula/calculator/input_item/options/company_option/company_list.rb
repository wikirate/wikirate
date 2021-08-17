module Formula
  class Calculator
    class InputItem
      module Options
        module CompanyOption
          # Used if the a comma separated is passed as company option
          # Example: {{ M1 | company: Death Star, SPECTRE }}
          # It makes the values for this input item independent of the output company
          # (since the value for the company of the company option is always used)
          module CompanyList
            extend AddValidationChecks
            include CompanyIndependentInput

            add_validation_checks :check_company_option

            def check_company_option
              object_companies.each do |comp|
                type_id = Card.fetch_type_id comp
                if !type_id
                  add_error "unknown card: #{comp}"
                elsif type_id != Card::WikirateCompanyID
                  add_error "not a company: #{comp}"
                end
              end
            end

            def year_value_pairs
              years_from_db(object_company_ids).each_with_object({}) do |y, h|
                h[y.to_i] = values_from_db object_company_ids, y
              end
            end

            def object_companies
              @object_companies ||= company_option.split(",")
            end

            def object_company_ids
              @object_company_ids ||= object_companies.map(&:card_id)
            end
          end
        end
      end
    end
  end
end
