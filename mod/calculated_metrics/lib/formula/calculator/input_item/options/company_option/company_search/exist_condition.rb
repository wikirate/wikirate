module Formula
  class Calculator
    class InputItem
      module Options
        module CompanyOption
          module CompanySearch
            # A {Condition} that checks only for the existence of a relationship like
            # Related[Jedi+more evil]
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
