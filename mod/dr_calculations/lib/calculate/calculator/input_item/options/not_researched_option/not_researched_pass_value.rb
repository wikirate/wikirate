class Calculate
  class Calculator
    class InputItem
      module Options
        module NotResearchedOption
          # Used if the "not researched" option is set to an arbitrary return value
          module NotResearchedPassValue
            def answer_for company_id, year
              super.tap do |a|
                if (nra = not_researched_answer a, company_id, year)
                  nra.replace_not_researched
                  return nra
                end
              end
            end

            def not_researched_answer answer, company_id, year
              return unless input_value_not_researched? answer
              return answer if answer

              InputAnswer.new self, company_id, year
            end

            def mandatory?
              false
            end

            def sort_index
              super + 2 * parser.input_count
            end
          end
        end
      end
    end
  end
end
