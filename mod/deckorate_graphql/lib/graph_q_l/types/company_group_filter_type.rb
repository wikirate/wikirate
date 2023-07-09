module GraphQL
  module Types
    class CompanyGroupFilterType < BaseEnum
      ::Card.fetch(:company_group).item_cards.each do |item|
        value item.card.name.url_key, value: item.card.name
      end
    end

  end
end
