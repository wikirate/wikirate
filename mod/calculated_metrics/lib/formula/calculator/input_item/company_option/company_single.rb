module Formula
  class Calculator
    class InputItem
      module CompanyOption
        module CompanySingle
          include CompanyIndependentInput

          def each_answer
            answers.each do |a|
              value = Answer.value_from_lookup a.value, type
              yield nil, a.year, value
            end
          end

          def values_by_year_for_each_company
            y_and_v = Answer.where(metric_id: card_id, company_id: object_company_id)
                  .pluck(:year, :value)
            yield nil, y_and_v.to_h
          end

          private

          def object_company_id
            Card.fetch_id company_option
          end

          def answer_query
            query = super
            query[:company_id] = object_company_id
            query
          end
        end
      end
    end
  end
end
