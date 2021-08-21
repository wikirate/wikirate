module Formula
  class Calculator
    class InputItem
      # To be included if the values of the input item don't depend on the output company
      # (because of company option)
      module CompanyIndependentInput
        def company_dependent?
          false
        end

        def sort_index
          super + parser.input_count
        end
      end
    end
  end
end
