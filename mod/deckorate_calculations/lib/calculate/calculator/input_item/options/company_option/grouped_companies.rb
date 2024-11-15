class Calculate
  class Calculator
    class InputItem
      module Options
        module CompanyOption
          # Used if a company group is passed as company option.
          # It makes the values for this input item independent of the output company
          # (since the answers for the company group are always used)
          module GroupedCompanies
            include CompanyIndependentInput

            # year => InputRecord
            def year_answer_pairs
              record_lists.each_with_object({}) do |(year, array), hash|
                hash[year] = consolidated_input_record array, year
              end
            end

            private

            # year => [Answer]
            def record_lists
              answer_relation.each_with_object({}) do |answer, hash|
                hash[answer.year] ||= []
                hash[answer.year] << answer
              end
            end

            def answer_relation
              query = { metric_id: input_card.id,
                        company_group: company_group.id,
                        published: :all }
              restrict_years query
              Card::RecordQuery.new(query).lookup_relation
            end

            def company_group
              company_option_card
            end
          end
        end
      end
    end
  end
end
