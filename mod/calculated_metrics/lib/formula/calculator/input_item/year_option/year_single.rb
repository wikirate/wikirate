module Formula
  class Calculator
    class InputItem
      module YearOption
        # Handles a year option with a single value
        # Examples:
        #    year: 1999  # use 1999 for all years
        #    year: -1    # use previous year
        #    year: 0     # use the same year as the calculated year
        #    year: 4     # 4 years in the future
        module YearSingle
          def process_year_option
            year_option.to_i.tap do |y|
              @fixed_year = year? y
            end
          end

          def translate_years years
            if @fixed_year
              years.include?(processed_year_option) ? all_years : []
            else
              years.map { |y| y - processed_year_option }
            end
          end
        end
      end
    end
  end
end
