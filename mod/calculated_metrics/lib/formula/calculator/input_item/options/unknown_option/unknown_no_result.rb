module Formula
  class Calculator
    class InputItem
      module Options
        module UnknownOption
          # Used if the "unknown" option is set to "no_result"
          module UnknownNoResult
            def update_result_slice company_id, year, value
              return super unless input_value_unknown? value
              @result_slice.remove company_id, year
            end
          end
        end
      end
    end
  end
end
