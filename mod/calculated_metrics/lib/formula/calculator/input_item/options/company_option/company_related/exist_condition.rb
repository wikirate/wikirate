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
            class ExistCondition
              include AbstractCondition
              def initialize string, id
                super
                @metric = string
                validate_metric
              end

              def sql
                "(#{metric_sql})"
              end
            end
          end
        end
      end
    end
  end
end
