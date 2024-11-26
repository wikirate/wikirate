class Calculate
  class Calculator
    class InputItem
      module Options
        module YearOption
          # Handles the year option that searches for latest for a given answer
          # Example:
          #    year: latest
          module YearLatest
            def process_year_option
              :latest
            end

            # @return an array of years for which values can be calculated out of the
            #   given list of years
            def translate_years _years
              all_years
            end

            def answer_query
              super.merge latest: true
            end
          end
        end
      end
    end
  end
end
