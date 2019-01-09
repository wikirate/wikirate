module Formula
  class Calculator
    class InputItem
      module Options
        module CompanyOption
          module CompanySearch
            class RelatedCondition
              module SingleInverse
                def object_sql
                  "r0.subject_company_id"
                end

                def subject_sql
                  "r0.object_company_id"
                end
              end
            end
          end
        end
      end
    end
  end
end
