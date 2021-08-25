class Calculate
  class Calculator
    class InputItem
      module Options
        module UnknownOption
          # Used if the "unknown" option is set to "result_unknown"
          # which means that the calculated value becomes "Unknown".
          module UnknownResultUnknown
            def answer_for company_id, year
              super.tap { |a| unknown! a if input_answer_unknown? a }
            end
          end
        end
      end
    end
  end
end
