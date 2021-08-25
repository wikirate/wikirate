class Calculate
  class Calculator
    class InputItem
      module Options
        module UnknownOption
          # Used if the "unknown" option is set to a specific value
          module UnknownPassValue
            def answer_for company_id, year
              super.tap do |a|
                a.replace_unknown if input_answer_unknown? a
              end
            end
          end
        end
      end
    end
  end
end
