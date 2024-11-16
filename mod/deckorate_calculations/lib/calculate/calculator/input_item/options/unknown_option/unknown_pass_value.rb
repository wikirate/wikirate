class Calculate
  class Calculator
    class InputItem
      module Options
        module UnknownOption
          # Used if the "unknown" option is set to a specific value
          module UnknownPassValue
            def record_for company_id, year
              super.tap do |a|
                a.replace_unknown if input_record_unknown? a
              end
            end
          end
        end
      end
    end
  end
end
