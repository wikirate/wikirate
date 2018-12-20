module Formula
  class Calculator
    class InputItem
      # To be included if the values of the input item don't depend on the output company.
      # Can be either a yearly variable or a metric with a fixed company as company
      # option.
      module CompanyIndependentInput
        def value_store_class
          YearlyValueStore
        end

        def update_result_slice _company_id, year
          @result_slice.add :all, year
        end

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
