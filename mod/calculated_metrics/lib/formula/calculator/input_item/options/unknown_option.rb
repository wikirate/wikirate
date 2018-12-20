module Formula
  class Calculator
    class InputItem
      module Options
        # Handle unknown options for input items of formula
        # Possible values:
        #   no_result:      (DEFAULT) store NO result of the ENTIRE formula
        #   result_unknown: the result of the ENTIRE formula is "Unknown"
        #   false: pass false (or "null") to the formula
        #   (any number):  pass the number to formula
        #   (any other string): pass value as string to formula
        module UnknownOption
          # extend AddValidationChecks
          # add_validation_checks :check_unknown_option

          def initialize_option
            super
            interpret_unknown_option
          end

          def check_unknown_option
            add_error "invalid unknown option: #{unknown_option}"
          end

          # input value has the value "Unknown"
          def input_value_unknown? value
            Array.wrap(value).any? { |val| Answer.unknown? val }
          end

          private

          def interpret_unknown_option
            case unknown_option
            when "no_result"      then extend UnknownNoResult
            when "result_unknown" then extend UnknownResultUnknown
            else
              extend UnknownPassValue
            end
          end
        end
      end
    end
  end
end
