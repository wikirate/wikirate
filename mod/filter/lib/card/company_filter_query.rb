class Card
  class CompanyFilterQuery < FilterQuery

    include WikirateFilterQuery

    def country_cql country
      add_to_cql :country, country
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

  module Query
    class CardQuery
      module CountryQuery
        def country_join
          Join.new side: :left,
                   from: self, from_field: "id",
                   to: %i[answers countries company_id]
        end

        def country_condition
          "countries.metric_id = #{Codename.id :core_country} AND countries.value IN (?)"
        end

        def country val
          joins << country_join

          @conditions << ::Answer.sanitize_sql_for_conditions(
            [country_condition, Array.wrap(val)]
          )
        end
      end
      include CountryQuery
    end

    attributes[:country] = :relational
  end
end
