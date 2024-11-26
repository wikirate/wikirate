class Calculate
  class Calculator
    class InputItem
      module Options
        module NotResearchedOption
          # Used if the "not_researched" option is set to "result_unknown" which means
          # that the calculated value becomes "Unknown".
          module NotResearchedResultUnknown
            def answer_for company_id, year
              super.tap { |a| unknown! a if input_value_not_researched? a }
            end
          end
        end
      end
    end
  end
end
