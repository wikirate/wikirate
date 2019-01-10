module Formula
  class Calculator
    class InputItem
      module Options
        module CompanyOption
          module CompanySearch
            # The base class for different types of conditions like {ExistCondition}
            # and {OperatorCondition}
            module InverseCondition
              def metric_sql
                tablefy "inverse_metric_id = #{@metric_id}"
              end

              def inverse?
                true
              end

              def join_table_sql
                <<-SQL.strip_heredoc
                  (
                   SELECT object_company_id as subject_company_id,
                          subject_company_id as object_company_id,
                          metric_id, inverse_metric_id,
                          year, value
                   FROM relationships 
                   WHERE inverse_metric_id = #{metric_id}
                  ) AS #{table}
                SQL
              end
            end
          end
        end
      end
    end
  end
end
