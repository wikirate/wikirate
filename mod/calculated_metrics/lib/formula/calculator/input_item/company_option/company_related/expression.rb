module Formula
  class Calculator
    class InputItem
      module CompanyOption
        module CompanyRelated
          class Expression
            attr_reader :metric_card, :value, :metric_id

            class Error < StandardError
            end

            SEPARATORS = %w[&& ||].freeze

            SPLIT_REGEX = # splits several expressions
              Regexp.new(SEPARATORS.map { |sep| /\)*\s#{Regexp.quote sep}\s*\(*/ }.join "|")

            OPERATOR_REGEX = Regexp.new Card::Query::OPERATORS.values.join("|")

            INVALID_VALUE_CHARS = /["';]/

            def initialize string, id
              @original = string
              @table_id = id
              match = string.match /^(.+)\s*(#{OPERATOR_REGEX})\s*(.+)$/
              raise Error, "invalid expression \"#{string}\"" unless match
              @metric, @operator, @value = match[1], match[2], match[3]
              validate
              @metric_id = @metric_card.id
            end

            def querify str
              str.sub(@original, "(#{metric_sql} && #{value_sql})")
            end

            def metric_sql
              "r#{@table_id}.metric_id = #{@metric_id}"
            end

            def value_sql
              "r#{@table_id}.#{"numeric_" if numeric_operator?}value #{@operator} \"#{@value}\""
            end

            private

            def numeric_operator?
              @operator.in? %w[< >]
            end

            def validate
              if @metric.blank? || @value.blank?
                raise Error, "invalid expression \"#{string}\""
              end
              @metric_card = Card.fetch @metric
              if @metric_card.nil? || @metric_card.type_id != Card::MetricID
                raise Error, "no a metric: \"#{@metric}\""
              end
            end

            def value_sql_safe?
              @value.sub!(/^["']/, "")
              @value.sub!(/["']$/, "")

              if @value.match INVALID_VALUE_CHARS
                raise Error, "value is not allowed to contain the "\
                           "characters #{ INVALID_VALUE_CHARS.to_sentence }"
              end
            end
          end
        end
      end
    end
  end
end
