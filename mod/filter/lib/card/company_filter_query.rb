class Card
  class CompanyFilterQuery < FilterQuery
    include WikirateFilterQuery

    class << self
      def country_condition
        answer_condition :countries, :core_country
      end

      def industry_condition
        answer_condition :industries, :commons_industry
      end

      def answer_condition table, codename
        "#{table}.metric_id = #{codename.card_id} AND #{table}.value IN (?)"
      end
    end

    def country_cql country
      add_to_cql :country, country
    end

    def industry_cql industry
      add_to_cql :industry, industry
    end

    def company_cql company
      name_cql company
    end
    alias wikirate_company_cql company_cql

    def company_group_cql group
      referred_to_by_company_list group
    end

    def project_cql project
      referred_to_by_company_list project
    end

    def referred_to_by_company_list trunk
      return unless trunk.present?
      # this "and" is a hack to prevent collision between the referred_to_by's
      add_to_cql :and, referred_to_by: Card::Name[trunk, :wikirate_company]
    end
  end

  # add :country attribute to Card::Query
  module Query
    attributes.merge! country: :relational, industry: :relational

    class CardQuery
      # extend CardQuery to look up companies' countries in card table
      module CountryQuery
        def country val
          joins << answer_join(:countries)
          add_answer_condition CompanyFilterQuery.country_condition, val
        end

        def industry val
          joins << answer_join(:industries)
          add_answer_condition CompanyFilterQuery.industry_condition, val
        end

        private

        def answer_join answer_alias
          Join.new side: :left, from: self, from_field: "id",
                   to: [:answers, answer_alias, :company_id]
        end

        def add_answer_condition cond, val
          @conditions << ::Answer.sanitize_sql_for_conditions([cond, Array.wrap(val)])
        end
      end
      include CountryQuery
    end
  end
end
