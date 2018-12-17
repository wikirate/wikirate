module Formula
  class Calculator
    class InputItem
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

          def each_answer
            years_from_db(object_company_ids).each do |year|
              yield nil, year, values_from_db(object_company_ids, year)
            end
          end

          def values_by_year_for_each_company
            v_by_y = years_from_db(object_company_ids).each_with_object({}) do |y, h|
              h[y.to_i] = values_from_db object_company_ids, y
            end
            yield nil, v_by_y
          end

          def object_companies
            @object_companies ||= company_option.split(",")
          end

          def object_company_ids
            @o_ids ||= object_companies.map { |comp| Card.fetch_id comp }
          end
        end
      end
    end
  end
end
