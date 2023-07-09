module GraphQL
  module Types
    class ValueFilterType < BaseEnum
      ::Card.fetch(:value_type).item_cards.each do |item|
        value item.card.name.url_key, value: item.card.name
      end
    end

  end
end
