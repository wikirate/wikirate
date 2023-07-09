module GraphQL
  module Types
    class MetricCategoryFilterType < BaseEnum
      ::Card.fetch(:metric_type_type).item_cards.each do |item|
        value item.card.name.url_key, value: item.card.name
      end
    end
  end
end