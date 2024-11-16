class Calculate
  class Calculator
    class InputItem
      module Options
        module NotResearchedOption
          # Used if the "not researched" option is set to an arbitrary return value
          module NotResearchedPassValue
            def record_for company_id, year
              super.tap do |a|
                if (nra = not_researched_record a, company_id, year)
                  nra.replace_not_researched
                  return nra
                end
              end
            end

            def not_researched_record record, company_id, year
              return unless input_value_not_researched? record
              return record if record

              InputRecord.new self, company_id, year
            end

            def mandatory?
              false
            end

            def sort_index
              super + 2 * input_count
            end
          end
        end
      end
    end
  end
end
