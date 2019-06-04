module Formula
  class Calculator
    class InputItem
      module Options
        module NotResearchedOption
          # Used if the "not_researched" option is set to "result_unknown" which means
          # that the calculated value becomes "Unknown".
          module NotResearchedResultUnknown
            def value_for company_id, year
              value = super
              return value unless input_value_not_researched? value

              throw(:cancel_calculation, :unknown)
            end
          end
        end
      end
    end
  end
end
