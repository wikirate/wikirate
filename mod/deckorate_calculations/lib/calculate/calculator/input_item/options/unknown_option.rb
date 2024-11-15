class Calculate
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
            if option? :unknown
              interpret_unknown_option
            else
              extend UnknownResultUnknown
            end
          end

          def unknown_option
            @unknown_option ||= option(:unknown)
          end

          def check_unknown_option
            add_error "invalid unknown option: #{unknown_option}"
          end

          # input value has the value "Unknown"
          def input_record_unknown? answer
            return if answer.is_a? Hash

            Array.wrap(answer&.value).any? { |v| Answer.unknown? v }
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
