module Formula
  class Calculator
    class InputItem
      module Options
        module NotResearchedOption
          # Used if the "not researched" option is set to an arbitrary return value
          module NotResearchedPassValue
            def value_for company_id, year
              replace_nil super
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
              return value unless input_value_not_researched?(value)

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
