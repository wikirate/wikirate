module Formula
  class Calculator
    class InputItem
      module Options
        module UnknownOption
          # Used if the "unknown" option is set to "result_unknown" which means
          # that the calculated value becomes "Unknown".
          module UnknownPassValue
            def value_for company_id, year
              replace_unknown super
            end

            def replace_unknown value
              return value unless input_value_unknown?(value)
              if value.is_a?(Array)
                value.map { |v| v.nil? ? unknown_option : v }
              else
                unknown_option
              end
            end
          end
        end
      end
    end
  end
end
