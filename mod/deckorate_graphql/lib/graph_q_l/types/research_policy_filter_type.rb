module GraphQL
  module Types
    class ResearchPolicyFilterType < BaseEnum
      description "Research Policy on a metric can be either CommunityAssessed (anyone can research answers) or DesignerAssessed (only the designer can)"
      ::Card.fetch(:research_policy).item_cards.each do |item|
        value item.card.name.url_key, value: item.card.name
      end
    end
  end
end