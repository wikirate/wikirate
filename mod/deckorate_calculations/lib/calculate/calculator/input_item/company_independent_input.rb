class Calculate
  class Calculator
    class InputItem
      # To be included if the values of the input item don't depend on the output company
      # (because of company option)
      module CompanyIndependentInput
        def company_dependent?
          false
        end

        def value_store_class
          YearlyValueStore
        end

        def input_answers_by_company_and_year
          { nil => year_answer_pairs }
        end

        def update_result_slice _company_id, year, _value
          @result_slice.add :all, year
        end

        def sort_index
          super + input_count
        end
      end
    end
  end
end
