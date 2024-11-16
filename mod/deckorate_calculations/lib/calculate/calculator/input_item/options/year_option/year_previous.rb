class Calculate
  class Calculator
    class InputItem
      module Options
        module YearOption
          # Handles the "previous" year option
          # Example:
          #    year: previous # use the last record before the current year
          module YearPrevious
            def process_year_option
              :previous
            end

            def translate_years years
              Array.wrap years.sort[1..-1]
            end
          end
        end
      end
    end
  end
end
