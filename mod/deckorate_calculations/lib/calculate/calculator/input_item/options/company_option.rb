class Calculate
  class Calculator
    class InputItem
      module Options
        # Handle company options for input items of formulas
        # Examples:
        # Case 1: explicit company
        #   company: "Death Star"
        # Case 2: explicit company group
        #   company: "Deadliest"
        # Case 2: related companies (answer output company is subject, inputs are objects)
        #   company: "Jedi+more evil"
        #
        # TODO: store company ids, not names!
        module CompanyOption
          extend AddValidationChecks

          add_validation_checks :check_company_option

          def initialize_option
            super
            interpret_company_option
          end

          def company_option
            @company_option ||= option :company
          end

          def company_option_card
            @company_option_card ||= company_option&.card
          end

          def check_company_option
            add_error @value_type_error if @value_type_error
          end

          # # used for CompanyOption
          # def combined_input_answers company_ids, year
          #   consolidated_input_answer sub_input_answers(company_ids, year), year
          # end
          #
          # def sub_input_answers company_ids, year
          #   rel = sub_answers_rel company_ids, year
          #   each_input_answer rel, [] do |input_answer, array|
          #     array << input_answer
          #   end
          # end
          #
          # def sub_answers_rel company_ids, year
          #   Answer.where metric_id: input_card.id, company_id: company_ids, year: year
          # end

          private

          def interpret_company_option
            case company_option_card&.type_code
            when :metric
              # TODO: validate relationship
              extend RelatedCompanies
            when :company_group
              extend GroupedCompanies
            when :wikirate_company
              extend SingleCompany
            else
              @value_type_error = "invalid company option: #{company_option}. " \
                                  "Must be company, company group, or relationship metric"
            end
          end
        end
      end
    end
  end
end
