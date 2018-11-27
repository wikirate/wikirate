module Formula
  class Calculator
    class Input
      class CompanyOptionParser

        class Expression
          attr_reader :metric_card, :value, :metric_id

          class Error < StandardError
          end

          SEPARATORS = %w[&& ||].freeze
          SPLIT_REGEX = SEPARATORS.map { |sep| /\)*\s#{Regexp.quote sep}\s*\(*/ }.join "|"

          def initialize string
            @metric, @value =
                          string.split Card::Query::OPERATORS.values.join("|")
            validate
            @metric_id = @metric_card.id
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
        end


        #   Related[Jedi+more evil >= 6 && Commons+Supplied by=Tier 1 Supplier]
        def initialize string
          @string = string
        end

        def parse
          case @string
          when /^\s*Related\[([^]]+)\]\s*$/
            related_parse $1
          when /^[\w\s+\d]/

          end
        end

        def related_parse string
          expr =
            string.split(Expression::SPLIT_REGEX).map do |part|
              Expression.new part.strip.gsub(/^\(*/).gsub(/\)*$/)
            end
          Relation.where(metric_id AND value >= 6)
        rescue Expression::Error => e

        end

        def query

        end

        def companies_and_years

        end

      end
    end
  end
end
