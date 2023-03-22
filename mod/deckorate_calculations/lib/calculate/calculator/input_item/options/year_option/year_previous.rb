class Calculate
  class Calculator
    class InputItem
      module Options
        module YearOption
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
