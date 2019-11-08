class Card
  class CompanyFilterQuery < FilterQuery
    def company_wql company
      name_wql company
    end
    alias wikirate_company_wql company_wql

    def company_group_wql group
      referred_to_by_company_list group
    end

    def project_wql project
      referred_to_by_company_list project
    end

    def referred_to_by_company_list trunk
      return unless trunk.present?
      # this "and" is a hack to prevent collision between the referred_to_by's
      add_to_wql :and, referred_to_by: Card::Name[trunk, :wikirate_company]
    end
  end
end
