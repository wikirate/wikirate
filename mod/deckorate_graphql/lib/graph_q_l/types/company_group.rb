module GraphQL
  module Types
    # CompanyGroup type for GraphQL
    class CompanyGroup < Card
      subcardtype_field :company, Company, :wikirate_company
    end
  end
end
