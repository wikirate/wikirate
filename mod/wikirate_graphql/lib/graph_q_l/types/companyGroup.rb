module GraphQL
  module Types
    # CompanyGroup type for GraphQL
    class CompanyGroup < Card
      field :companies, [Company], null: false do
        # argument :limit, Integer, required: false
        # argument :offset, Integer, required: false
      end

      def companies # limit, offset
        object.wikirate_company_card.item_cards # limit: limit, offset: offset
      end
    end
  end
end
