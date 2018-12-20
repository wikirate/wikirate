module Formula
  class Calculator
    class InputItem
      module Options
        module UnknownOption
          # Used if the "unknown" option is set to "result_unknown" which means
          # that the calculated value becomes "Unknown".
          module UnknownNoResult
            def value_for company_id, year
              value = super
              return value unless input_value_unknown? value
              throw(:cancel_calculation, :unknown)
            end
          end
        end
      end
    end
  end
end
