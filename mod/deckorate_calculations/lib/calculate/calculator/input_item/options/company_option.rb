class Calculate
  class Calculator
    class InputItem
      module Options
        # Handle company options for input items of formulas
        # Examples:
        # Case 1a: explicit company
        #   {{Jedi+deadliness|company:"Death Star"}}
        # Case 1b: explicit company list
        #   {{Jedi+deadliness|company:"Death Star", "SPECTRE"}}
        # Case 2: related companies
        #   {{Jedi+deadliness|company:Related[Jedi+more evil=yes]}}
        #   {{Jedi+deadliness|company:Related[Jedi+more evil>=6]}}
        #   {{Jedi+deadliness|company:Related[Jedi+more evil>=6 &&
        #                                   Commons+Supplied by=Tier 1 Supplier]}}
        module CompanyOption
          def initialize_option
            super
            interpret_company_option
          end

          def year_value_pairs_by_company
            { nil => year_answer_pairs }
          end

          def company_option
            @company_option ||= option(:company)
          end

          private

          def interpret_company_option
            case company_option
            when /Related\[([^\]]*)\]/
              extend CompanySearch
            when /&&/
              extend CompanyQuery
            when /,/
              extend CompanyList
            else
              extend CompanySingle
            end
          end
        end
      end
    end
  end
end
