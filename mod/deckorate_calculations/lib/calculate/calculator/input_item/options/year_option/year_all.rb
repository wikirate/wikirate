class Calculate
  class Calculator
    class InputItem
      module Options
        module YearOption
          # Handles the year option that searches for all
          # existing years for a given answer
          # Example:
          #    year: all
          module YearAll
            def process_year_option
              :all
            end

            # @return an array of years for which values
            # can be calculated out of the
            # given list of years
            def translate_years _years
              all_years
            end
          end
        end
      end
    end
  end
end
