module GraphQL
  module Types
    # CompanyGroup type for GraphQL
    class CompanyGroup < DeckorateCard
      field :companies, [Company], null: true

      def companies
        object.wikirate_company_card.item_cards
      end
    end
  end
end
