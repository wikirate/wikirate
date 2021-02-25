module Formula
  class Calculator
    class InputItem
      module Options
        module YearOption
          # Handles the year option that searches for latest for a given record
          # Example:
          #    year: latest
          module YearLatest
            def process_year_option
              :latest
            end

            # @return an array of years for which values can be calculated out of the
            #   given list of years
            def translate_years years
              all_years
            end
          end
        end
      end
    end
  end
end
