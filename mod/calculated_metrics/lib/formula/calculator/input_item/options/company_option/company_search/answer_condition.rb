module Formula
  class Calculator
    class InputItem
      module Options
        module CompanyOption
          module CompanySearch
            class AnswerCondition
              require_dependency "condition"

              class << self
                def new string, id
                  Condition.new_obj(string, id).tap do |con|
                    con.extend AnswerConditionMethods
                    con.validate
                  end
                end
              end

              module AnswerConditionMethods
                def table
                  "a#{@table_id}"
                end

                def join_sql
                  "LEFT JOIN answers AS #{table} "\
                  "ON r0.object_company_id = #{table}.company_id && "\
                  "r0.year = #{table}.year"
                end

                def validate_metric_type
                  if @metric_card.relationship?
                    raise Condition::Error,
                          "\"#{@metric}\" is a relationship metric. "\
                          "Use the Related[] method for relationship conditions."
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
