module Formula
  class Calculator
    class InputItem
      module Options
        module NotResearchedOption
          # Used if the "not researched" option is set to an arbitrary return value
          module NotResearchedPassValue
            def value_for company_id, year
              value = super
              value.nil? ? not_researched_option : value
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
