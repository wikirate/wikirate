module Formula
  class Calculator
    class InputItem
      module Options
        module CompanyOption
          module CompanySearch
            module SqlHelper
              def in_or_eq vals
                if vals.size > 1
                  "IN (#{vals.join ','})"
                else
                  "= #{vals.first}"
                end
              end
            end
          end
        end
      end
    end
  end
end
