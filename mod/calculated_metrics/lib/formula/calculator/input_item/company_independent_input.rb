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

        def store_value company_id, year, value
          # We skip the result_space update here.
          # In principle, we have to add all existing companies here for the
          # case that the formula has only company independent input items.
          # That seems too unlikely to justify this horrible slow move.
          value_store.add company_id, year, value
          @result_slice.add :all, year
        end

        def sort_index
          super + parser.input_count
        end
      end
    end
  end
end
