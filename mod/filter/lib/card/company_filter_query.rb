class Card
  class CompanyFilterQuery < FilterQuery
    include WikirateFilterQuery

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
end
