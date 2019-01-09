module Formula
  class Calculator
    class InputItem
      module Options
        module CompanyOption
          module CompanySearch
            class RelatedCondition
              module OrChain
                def select_from_sql
                  return super unless any_inverse?
                  <<-SQL.strip_heredoc
                    (
                     SELECT subject_company_id, object_company_id,
                            metric_id, inverse_metric_id, year, value
                     FROM relationships
                     WHERE metric_id #{in_or_eq metric_ids} 
                     UNION
                     SELECT object_company_id as subject_company_id,
                            subject_company_id as object_company_id,
                            metric_id, inverse_metric_id, year, value
                     FROM relationships
                     WHERE inverse_metric_id #{in_or_eq inverse_metric_ids}
                    ) AS r0
                  SQL
                end

                def where_sql
                  @conditions.map(&:where_sql).join " OR "
                end

                def add_condition str, _index
                  @conditions << Condition.new(str, 0)
                end
              end
            end
          end
        end
      end
    end
  end
end
