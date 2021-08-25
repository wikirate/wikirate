class Calculate
  class Calculator
    class InputItem
      module Options
        module CompanyOption
          # Used if a "Related" search expression is passed as company option
          # Example:
          #   {{ M1 | company: Related[M2 >= 6 && M3=Tier 1 Supplier] && M4 > 10 }}
          #
          # In contrast to the other company options {CompanyList} and {CompaanySinge},
          # this case is company dependent.
          module CompanySearch
            include CompanyDependentInput
            extend AddValidationChecks
            add_validation_checks :check_related_conditions

            def check_related_conditions
              CompanyQuery.new(company_option, nil).validate
            rescue Condition::Error => e
              add_error e.message
            end

            def year_value_pairs_by_company
              relations.each_with_object({}) do |(subject_company_id, answers), hash|
                hash[subject_company_id] ||= {}
                answers.each do |year, object_company_ids|
                  v = combined_input_answers object_company_ids, year
                  hash[subject_company_id][year] = v if v.present?
                end
              end
            end

            # @return hash with format
            #   { subject_company_id => { year => Array<object_company_id> } }
            #   Each of these relations satifies the "Related" condition in the formula
            #   At this point we haven't checked if the input metric has actually an
            #   answer for these object_companies
            def relations
              @relations ||=
                CompanyQuery.new(company_option, search_space).relations
            end
          end
        end
      end
    end
  end
end
