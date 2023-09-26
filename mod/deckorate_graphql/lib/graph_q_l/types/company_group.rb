module GraphQL
  module Types
    # CompanyGroup type for GraphQL
    class CompanyGroup < WikirateCard
      cardtype_field :company, Company, :wikirate_company, true
    end
  end
end
