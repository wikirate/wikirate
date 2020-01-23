module Formula
  class Calculator
    class InputItem
      module Options
        module CompanyOption
          module CompanySearch
            # Handles conditions outside of the 'Related' conditions that refer
            # to non-relationship metrics like M2 in the following example:
            #   Related[M1] && M2 > 4
            class AnswerCondition
              class << self
                def new string, id
                  Condition.new_obj(string, id).tap do |con|
                    con.extend AnswerConditionMethods
                    con.validate
                  end
                end
              end

              # Contains modifications needed to turn a relationship metric condition
              # into a non-relationship metric condition.
              # The main difference is that the sql has to query the answer table
              # instead of the relationship table.
              #
              # The first condition of the full sql query is always build by a
              # relationship condition,
              # hence we need for this case only a modified join sql.
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
                  return unless @metric_card.relationship?

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
