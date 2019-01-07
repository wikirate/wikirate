module Formula
  class Calculator
    class InputItem
      module Options
        module CompanyOption
          module CompanyRelated
            # A {Condition} refers to one relationship metric condition in a
            # Related[] expression for a company option.
            # For example:
            #   Related[Jedi+more evil>=6 && Commons+Supplied by=Tier 1 Supplier]}}]
            #   consists of the two conditions
            #     "Jedi+more evil>=6" and "Commons+Supplied by=Tier 1 Supplier"
            #
            # An instance of {Condition} can parse such an expresion and
            # search for all relationship answers that satisfy that condition.
            module AbstractCondition
              attr_reader :metric_card, :metric_id

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

              def metric_sql
                "r#{@table_id}.metric_id = #{@metric_id}"
              end

              private

              def validate_metric
                raise Condition::Error, "invalid expression \"#{string}\"" if @metric.blank?

                @metric_card = Card.fetch @metric
                if @metric_card.nil? || @metric_card.type_id != Card::MetricID
                  raise Condition::Error, "not a metric: \"#{@metric}\""
                end
                unless @metric_card.relationship?
                  raise Condition::Error, "expected a relationship metric: \"#{@metric}\""
                end
                @metric_id = @metric_card.id
              end
            end
          end
        end
      end
    end
  end
end
