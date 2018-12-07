module Formula
  class Calculator
    class InputItem
      module YearOption
        module YearSingle
          def process_year_option
            y = year_option.to_i
            @fixed_year = year? y
          end

          def translate_years years
            if @fixed_year
              years.include? @processed_year_option ? all_years : []
            else
              years.map { |y| y - @processed_year_option }
            end
          end
        end
      end
    end
  end
end
