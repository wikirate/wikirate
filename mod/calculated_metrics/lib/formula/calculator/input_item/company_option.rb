module Formula
  class Calculator
    class InputItem
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
      # Commons+Supplied by=Tier 1 Supplier]}}]'
      module CompanyOption
        def initialize_decorator
          super
          interpret_company_option
        end

        private

        def interpret_company_option
          case company_option
          when /^\s*Related\[([^\]]+)\]\s*$/
            @company_option = Regexp.last_match(1)
            extend CompanyRelated
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
