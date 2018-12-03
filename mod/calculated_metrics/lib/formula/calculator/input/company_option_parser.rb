module Formula
  class Calculator
    class Input
      class CompanyOptionParser
        RELATED_SELECT = "SELECT r0.subject_company_id, r0.year, "\
                         "GROUP_CONCAT(r0.object_company_id SEPARATOR '##') "\
                         "FROM relationships AS r0".freeze
        RELATED_GROUP_BY = "GROUP BY r0.subject_company_id, r0.year"

        def related_sql expr_count, wheres
          [RELATED_SELECT,
           joins(expr_count - 1),
           "WHERE #{wheres}",
           RELATED_GROUP_BY].flatten.compact.join " "
        end

        def joins count
          count.times.map { |no| related_join no  }
        end

        def related_join_sql no
          "JOIN relationships AS r#{no} "\
          "ON r0.object_company_id = r#{no}.object_company_id && "\
          "r0.subject_company_id = r#{no}.subject_company_id && "\
          "r0.year = r#{no}.year"
        end

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
            str.sub(@original, value_sql)
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

        #   Related[Jedi+more evil >= 6 && Commons+Supplied by=Tier 1 Supplier]
        def initialize string
          @string = string
        end

        def companies_and_years company_space=nil, year_space=nil
          ActiveRecord::Base.connection.select_rows(sql).map do |sc_id, year, oc_ids|
            [sc_id, year, oc_ids.split("##").map(&:to_i)]
          end
        end


        def sql
          case @string
          when /^\s*Related\[([^]]+)\]\s*$/
            related_parse $1
          when /^[\w\s+\d]/
            explicit_company_parse
          end
        end

        def related_parse string
          exprs =
            string.split(Expression::SPLIT_REGEX).map.with_index do |part, i|
              Expression.new part.strip.sub(/^\(*/, "").sub(/\)*$/, ""), i
            end

          value_wheres =
            exprs.inject(string) do |res, expr|
              expr.querify(res)
            end
          metric_wheres =
            exprs.map(&:metric_sql).join " && "
          related_sql exprs.size, "(#{metric_wheres}) && (#{value_wheres})"
        rescue Expression::Error => e
        end

        def explicit_company_parse

        end

        def query

        end


      end
    end
  end
end
