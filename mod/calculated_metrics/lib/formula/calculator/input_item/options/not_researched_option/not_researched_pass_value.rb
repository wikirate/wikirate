module Formula
  class Calculator
    class InputItem
      module Options
        module NotResearchedOption
          # Used if the "not researched" option is set to an arbitrary return value
          module NotResearchedPassValue
            def answer_for company_id, year
              super.tap do |answer|
                if answer && input_value_not_researched?(answer.value)
                  answer.value = answer.value = replace_nil answer.value
                end
              end
            end

            def not_researched_value
              case not_researched_option
              when "false" then false
              # when /^[+-]?\d+$/
              #   not_researched_option.to_i  casting happens later
              else
                not_researched_option
              end
            end

            def replace_nil value
              if value.is_a?(Array)
                value.map { |v| v.blank? ? not_researched_value : v }
              else
                not_researched_value
              end
            end

            def mandatory?
              false
            end

            def sort_index
              super + 2 * parser.input_count
            end
          end
        end
      end
    end
  end
end
