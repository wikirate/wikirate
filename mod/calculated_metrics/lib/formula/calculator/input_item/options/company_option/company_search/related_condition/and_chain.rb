module Formula
  class Calculator
    class InputItem
      module Options
        module CompanyOption
          module CompanySearch
            class RelatedCondition
              module AndChain
                def where_sql
                  @conditions.map(&:where_sql).join " AND "
                end

                def select_from_sql
                  return super unless @conditions.first.inverse?
                  <<-SQL.strip_heredoc
                    (
                      SELECT object_company_id as subject_company_id,
                             subject_company_id as object_company_id,
                             metric_id, inverse_metric_id, year, value
                      FROM relationships
                    ) AS r0
                  SQL
                end

                def join_sql
                  @conditions[1..-1].map(&:join_sql)
                end
              end
            end
          end
        end
      end
    end
  end
end
