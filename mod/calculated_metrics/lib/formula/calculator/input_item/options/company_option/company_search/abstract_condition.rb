module Formula
  class Calculator
    class InputItem
      module Options
        module CompanyOption
          module CompanySearch
            # The base class for different types of conditions like {ExistCondition}
            # and {OperatorCondition}
            module AbstractCondition
              attr_reader :metric_card, :metric_id

              def initialize string, id
                @original = string
                @table_id = id
              end

              def validate
                validate_metric
              end

              def where_sql
                raise "override me"
              end

              def subject_sql
                @subject_sql ||= tablefy "subject_company_id"
              end

              def object_sql
                @object_sql ||= tablefy "object_company_id"
              end

              def metric_sql
                tablefy "metric_id = #{@metric_id}"
              end

              def inverse?
                false
              end

              def join_sql
                <<-SQL.strip_heredoc
                  LEFT JOIN #{join_table_sql}
                  ON r0.subject_company_id = #{subject_sql} &&
                     r0.object_company_id = #{object_sql} &&
                     r0.year = r#{@table_id}.year
                SQL
              end

              def join_table_sql
                "relationships AS #{table}"
              end

              private

              def table
                "r#{@table_id}"
              end

              def tablefy str
                "#{table}.#{str}"
              end

              def validate_metric
                raise Condition::Error, "invalid expression \"#{@original}\"" if @metric.blank?

                @metric_card = Card.fetch @metric
                if @metric_card.nil? || @metric_card.type_id != Card::MetricID
                  raise Condition::Error, "not a metric: \"#{@metric}\""
                end
                validate_metric_type

                @metric_id = @metric_card.id
              end

              # a bit hacky
              # AnswerCondition overrides this and avoid the inverse stuff by doing that
              def validate_metric_type
                unless @metric_card.relationship?
                  raise Condition::Error, "expected a relationship metric: \"#{@metric}\""
                end
                extend InverseCondition if @metric_card.inverse?
              end
            end
          end
        end
      end
    end
  end
end
