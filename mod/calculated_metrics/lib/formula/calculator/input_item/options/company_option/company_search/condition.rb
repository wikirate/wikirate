# require_relative "operator_condition"
# require_relative "exist_condition"

module Formula
  class Calculator
    class InputItem
      module Options
        module CompanyOption
          module CompanySearch
            # Selects the right condition class for a condition given as a string.
            # For example:
            #   Related[Jedi+more evil>=6 && Commons+Supplied by=Tier 1 Supplier]}}]
            #   consists of the two conditions
            #     "Jedi+more evil>=6" and "Commons+Supplied by=Tier 1 Supplier"
            # An instance can parse such an expresion and search for all relationship
            # answers that satisfy that condition.
            class Condition
              require_dependency "operator_condition"
              require_dependency "exist_condition"

              class Error < StandardError
              end

              SEPARATORS = %w[&& ||].freeze

              splitter = SEPARATORS.map { |sep| /\)*\s#{Regexp.quote sep}\s*\(*/ }
                                   .join("|")
              SPLIT_REGEX = Regexp.new(splitter) # splits several expressions

              SYMBOL_OPERATORS = %w[!= = =~ < > ~].freeze
              WORD_OPERATORS = ["in", "not in"].freeze
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
end
