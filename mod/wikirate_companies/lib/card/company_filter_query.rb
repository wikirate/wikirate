class Card
  class CompanyFilterQuery < WikirateFilterQuery
    class << self
      def country_condition
        answer_condition :countries, :core_country
      end

      def category_condition
        answer_condition :categories, :commons_company_category
      end

      def company_answer_conditions val
        Array.wrap(val).map do |constraint|
          subq = company_answer_subquery constraint
          subq && "(#{subq})"
        end.compact.join " OR "
      end

      private

      def company_answer_subquery constraint
        return unless metric_id = constraint[:metric_id]

        query = [safe_clause("metric_id = ?", metric_id)]
        query << year_clause(constraint[:year])
        query.compact.join " AND "
      end

      def year_clause year
        case year
        when "", nil, "any"
          nil
        when "latest"
          "co_ans.latest is true"
        else
          safe_clause "year in (?)", year
        end
      end

      def safe_clause field, val
        ::Answer.sanitize_sql_for_conditions ["co_ans.#{field}", Array.wrap(val)]
      end


      def answer_condition table, codename
        "#{table}.metric_id = #{codename.card_id} AND #{table}.value IN (?)"
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
