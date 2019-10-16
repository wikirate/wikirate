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
      add_to_wql :referred_to_by, Card::Name[trunk, :wikirate_company]
    end
  end
end
