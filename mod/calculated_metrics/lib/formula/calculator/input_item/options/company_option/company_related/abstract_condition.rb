module Formula
  class Calculator
    class InputItem
      module Options
        module CompanyOption
          module CompanyRelated
            # The base class for different types of conditions like {ExistCondition}
            # and {OperatorCondition}
            module AbstractCondition
              attr_reader :metric_card, :metric_id, :subject_sql, :object_sql

              def initialize string, id
                @original = string
                @table_id = id
              end

              def querify str
                str.sub(@original, sql)
              end

              def sql
                raise "override me"
              end

              def subject_sql
                @subject_sql ||= tablefy "#{subject}_company_id"
              end

              def object_sql
                @object_sql ||= tablefy "#{object}_company_id"
              end

              def metric_sql
                tablefy "metric_id = #{@metric_id}"
              end

              def inverse?
                @inverse
              end

              def subject
                inverse? ? "object" : "subject"
              end

              def object
                inverse? ? "subject" : "object"
              end

              private

              def tablefy str
                "r#{@table_id}.#{str}"
              end

              def validate_metric
                raise Condition::Error, "invalid expression \"#{string}\"" if @metric.blank?

                @metric_card = Card.fetch @metric
                if @metric_card.nil? || @metric_card.type_id != Card::MetricID
                  raise Condition::Error, "not a metric: \"#{@metric}\""
                end
                unless @metric_card.relationship?
                  raise Condition::Error, "expected a relationship metric: \"#{@metric}\""
                end

                invert_metric if @metric_card.inverse?
                @metric_id = @metric_card.id
              end

              def invert_metric
                @metric_card = @metric_card.inverse_card
                @inverse = true
              end

            end
          end
        end
      end
    end
  end
end
