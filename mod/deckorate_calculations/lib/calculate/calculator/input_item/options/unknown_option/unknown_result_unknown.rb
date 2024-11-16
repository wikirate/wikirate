class Calculate
  class Calculator
    class InputItem
      module Options
        module UnknownOption
          # Used if the "unknown" option is set to "result_unknown"
          # which means that the calculated value becomes "Unknown".
          module UnknownResultUnknown
            def record_for company_id, year
              super.tap { |a| unknown! a if input_record_unknown? a }
            end
          end
        end
      end
    end
  end
end
