module Formula
  class Calculator
    class InputItem
      module Options
        module UnknownOption
          # Used if the "unknown" option is set to a specific value
          module UnknownPassValue
            def answer_for company_id, year
              super.tap do |answer|
                if input_value_unknown? answer.value
                  replace_unknown answer.value
                end
              end
            end

            def replace_unknown value
              if value.is_a?(Array)
                value.map { |v| input_value_unknown?(v) ? unknown_option : v }
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
