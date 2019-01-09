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
                     SELECT rr0.subject_company_id, rr0.object_company_id , rr0.metric_id, 
                            rr0.year, rr0.value
                     FROM relationships rr0
                     WHERE rr0.metric_id #{in_or_eq metric_ids} 
                     UNION
                     SELECT rr1.object_company_id as subject_company_id, 
                            rr1.subject_company_id as object_company_id, 
                            rr1.metric_id, rr1.year, rr1.value
                     FROM relationships rr1
                     WHERE rr1.inverse_metric_id #{in_or_eq inverse_metric_ids}
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
