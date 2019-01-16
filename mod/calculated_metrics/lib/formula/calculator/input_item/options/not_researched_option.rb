module Formula
  class Calculator
    class InputItem
      module Options
        # Handle not_researched options for input items of formula
        # Possible values:
        #   no_result:      (DEFAULT) store NO result of the ENTIRE formula
        #   result_unknown: the result of the ENTIRE formula is "Unknown"
        #   false: pass false (or "null") to the formula
        #   (any number):  pass the number to formula
        #   (any other string): pass value as string to formula
        module NotResearchedOption
          # VALID_UNKNOWN_VALUES = ::Set.new(%i[cancel return pass]).freeze
          #
          # extend AddValidationChecks
          # add_validation_checks :check_unknown_option

          def initialize_option
            super
            interpret_not_researched_option
          end

          # input value has "not researched" value
          def input_value_not_researched? value
            value.blank? || Array.wrap(value).any?(&:blank?)
          end

          private

          def interpret_not_researched_option
            case not_researched_option
            when "no_result"      then extend NotResearchedNoResult
            when "result_unknown" then extend NotResearchedResultUnknown
            else
              extend NotResearchedPassValue
            end
          end
        end
      end
    end
  end
end
