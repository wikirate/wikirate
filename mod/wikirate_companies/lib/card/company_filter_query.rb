class Card
  class CompanyFilterQuery < WikirateFilterQuery
    class << self
      def country_condition
        answer_condition :countries, :core_country
      end

      def category_condition
        answer_condition :categories, :commons_company_category
      end

      def company_answer_condition table, constraint
        AnswerCondition.new(table, constraint).sql
      end

      private

      def answer_condition table, codename
        "#{table}.metric_id = #{codename.card_id} AND #{table}.value IN (?)"
      end

      class AnswerCondition
        def initialize table, constraint
          @table = table
          @metric = constraint[:metric_id].to_i.card
          @year = constraint[:year]
          @value = constraint[:value]
          @group = constraint[:related_company_group]
        end

        def sql
          [metric_clause, year_clause, value_clause, related_clause]
            .compact.join " AND "
        end

        def metric_clause
          safe_clause "metric_id = ?", @metric.id
        end

        def year_clause
          case @year
          when "", nil, "any"
            nil
          when "latest"
            "#{@table}.latest is true"
          else
            safe_clause "year in (?)", @year
          end
        end

        def related_clause
          return unless @group.present?

          safe_clause "answer_id in (?)", Relationship.answer_ids_for(@metric, @group)
        end

        # TODO: reuse more code from value_filters.rb (logic is largely the same)
        def value_clause
          case @value
          when Array
            category_value_clause
          when Hash
            numeric_value_clause
          when "", nil
            nil
          else
            safe_clause "value LIKE ?", "%#{@value.strip}%"
          end
        end

        def numeric_value_clause
          bits = []
          add_numeric_value_subclause bits, :from, ">"
          add_numeric_value_subclause bits, :to, "<"
          bits.present? ? "(#{bits.join ' AND '})" : ""
        end

        def add_numeric_value_subclause array, word, sign
          return unless @value[word].present?

          array << safe_clause("numeric_value #{sign} ?", @value[word])
        end

        def category_value_clause
          if @metric.multi_categorical?
            # see comment in value_filters.rb
            ::Answer.sanitize_sql_for_conditions(
              ["FIND_IN_SET(?, REPLACE(#{@table}.value, ', ', ','))",
               Array.wrap(@value)]
            )
          else
            safe_clause "value in (?)", @value
          end
        end

        def safe_clause field, val
          ::Answer.sanitize_sql_for_conditions ["#{@table}.#{field}", Array.wrap(val)]
        end
      end
    end

    def country_cql country
      add_to_cql :company_country, country
    end

    def company_category_cql company_category
      add_to_cql :company_category, company_category
    end

    def company_answer_cql company_answer
      add_to_cql :company_answer, company_answer
    end

    def company_cql company
      name_cql company
    end
    alias wikirate_company_cql company_cql

    def company_group_cql group
      referred_to_by_company_list group
    end

    def dataset_cql dataset
      referred_to_by_company_list dataset
    end

    def referred_to_by_company_list trunk
      return unless trunk.present?
      # this "and" is a hack to prevent collision between the referred_to_by's
      add_to_cql :and, referred_to_by: Card::Name[trunk, :wikirate_company]
    end
  end

  # add :company_country, company_category, and company_answer attribute to Card::Query
  module Query
    attributes.merge! company_country: :conjunction,
                      company_category: :conjunction,
                      company_answer: :conjunction
    # FIXME: conjunction is weird here, but unlike :relational it passes on arrays

    CardQuery.include CompanyAnswerQuery
  end
end
