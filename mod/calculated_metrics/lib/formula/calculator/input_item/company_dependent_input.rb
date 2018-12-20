module Formula
  class Calculator
    class InputItem
      # To be included if the values of the input item depend on the output company.
      # Can be either a metric or a yearly variable with related company option.
      module CompanyDependentInput
        def value_store_class
          ValueStore
        end

        def companies_with_values
          value_store.companies
        end

        def company_dependent?
          true
        end

        def update_result_slice company_id, year
          @result_slice.add company_id, year
        end
      end
    end
  end
end
