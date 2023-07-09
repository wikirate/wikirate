module GraphQL
  module Types
    class TopicFilterType < BaseEnum
      ::Card.fetch(:wikirate_topic).item_cards.each do |topic|
        value topic.card.name.url_key, value: topic.card.name
      end
    end
  end
end