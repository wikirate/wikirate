class Calculate
  class Calculator
    class InputItem
      module Options
        # Handle company options for input items of formulas
        # Examples:
        # Case 1a: explicit company
        #   Total[{{Jedi+deadliness|company:"Death Star"}}]'
        # Case 1b: explicit company list
        #   Total[{{Jedi+deadliness|company:"Death Star", "SPECTRE"}}]'
        # Case 2: related companies
        #   Total[{{Jedi+deadliness|company:Related[Jedi+more evil=yes]}}]'
        #   Total[{{Jedi+deadliness|company:Related[Jedi+more evil>=6]}}]'
        #   Total[{{Jedi+deadliness|company:Related[Jedi+more evil>=6 &&
        #                                   Commons+Supplied by=Tier 1 Supplier]}}]'
        module CompanyOption
          def initialize_option
            super
            interpret_company_option
          end

          def year_value_pairs_by_company
            { nil => year_answer_pairs }
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
