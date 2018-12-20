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
            class OperatorCondition
              include AbstractCondition
              attr_reader :value

              INVALID_VALUE_CHARS = /["';]/

              def initialize string, id
                super
                match = string.match(/^(.+)\s*(#{Condition::OPERATOR_MATCHER})\s*(.+)$/m)
                raise Condition::Error, "invalid expression \"#{string}\"" unless match

                @metric = match[1]
                @operator = match[2]
                @value = match[3]
                validate_metric
                validate_value
              end

              def sql
                "(#{metric_sql} && #{value_sql})"
              end

              def value_sql
                "r#{@table_id}.#{'numeric_' if numeric_operator?}value "\
              "#{@operator} \"#{@value}\""
              end

              private

              def numeric_operator?
                @operator.in? %w[< >]
              end

              def validate_value
                raise Condition::Error, "invalid expression \"#{string}\"" if @value.blank?

                value_sql_safe?
              end

              def value_sql_safe?
                @value.sub!(/^["']/, "")
                @value.sub!(/["']$/, "")
                return unless @value.match? INVALID_VALUE_CHARS

                raise Condition::Error, "value is not allowed to contain the "\
                                      "characters #{INVALID_VALUE_CHARS.to_sentence}"
              end
            end
          end
        end
      end
    end
  end
end
