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
            #   Related[Jedi+more evil && Commons+Supplied by=Tier 1 Supplier]}}]
            #   consists of a {ExistCondition} "Jedi+more evil" and a
            #   {OperatorCondition} "Commons+Supplied by=Tier 1 Supplier"
            # An instance can parse such an expresion and build the sql that is needed to
            # to compose the search for all relationship answers that satisfy that
            # condition.
            class Condition
              class Error < Card::Error::UserError
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
                  new_obj(string, id).tap(&:validate)
                end

                def new_obj string, id
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
