class Calculate
  class Calculator
    class InputItem
      module Options
        module CompanyOption
          # Used if a company group is passed as company option.
          # It makes the values for this input item independent of the output company
          # (since the records for the company group are always used)
          module GroupedCompanies
            include CompanyIndependentInput

            # year => InputRecord
            def year_record_pairs
              record_lists.each_with_object({}) do |(year, array), hash|
                hash[year] = consolidated_input_record array, year
              end
            end

            private

            # year => [Record]
            def record_lists
              record_relation.each_with_object({}) do |record, hash|
                hash[record.year] ||= []
                hash[record.year] << record
              end
            end

            def record_relation
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
