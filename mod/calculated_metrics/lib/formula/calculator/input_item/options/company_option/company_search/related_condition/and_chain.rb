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
                      SELECT rr0.object_company_id as subject_company_id, 
                             rr0.subject_company_id as object_company_id, 
                             rr0.metric_id, rr0.year, rr0.value
                      FROM relationships rr0
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
