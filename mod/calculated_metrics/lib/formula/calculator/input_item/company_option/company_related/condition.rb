# require_relative "operator_condition"
# require_relative "exist_condition"

module Formula
  class Calculator
    class InputItem
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
          class Condition
            require_dependency "operator_condition"
            require_dependency "exist_condition"

            class Error < StandardError
            end

            SEPARATORS = %w[&& ||].freeze

            SPLIT_REGEX = # splits several expressions
              Regexp.new(SEPARATORS.map { |sep| /\)*\s#{Regexp.quote sep}\s*\(*/ }.join("|"))

            SYMBOL_OPERATORS = %w[!= = =~ < > ~]
            WORD_OPERATORS = ["in", "not in"]
            OPERATOR_MATCHER = (SYMBOL_OPERATORS +
                              WORD_OPERATORS.map { |w| "\\s+#{w}\\s+" }).join("|")

            class << self
              def new string, id
                if /#{OPERATOR_MATCHER}/m.match?(string)
                  OperatorCondition.new string, id
                else
                  ExistCondition.new string, id
                end
              end
            end
          end
        end
      end
    end
  end
end
