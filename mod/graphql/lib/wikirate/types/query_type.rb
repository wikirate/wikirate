module Wikirate
  module Types
    class QueryType < Types::BaseObject
      # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
      # include GraphQL::Types::Relay::HasNodeField
      # include GraphQL::Types::Relay::HasNodesField

      # Add root-level fields here.
      # They will be entry points for queries on your schema.

      field :card, Card, null: true do
        argument :name, String, required: false
        argument :id, Integer, required: false
      end

      field :cards, [Card], null: false do
        argument :name, String, required: false
      end

      field :company, Company, null: true do
        argument :name, String, required: false
        argument :id, Integer, required: false
      end

      field :companies, [Company], null: false do
        argument :name, String, required: false
      end

      def card **mark
        ok_card nil, **mark
      end

      def cards name: nil
        card_search name
      end

      def company **mark
        ok_card :wikirate_company, **mark
      end

      def companies name: nil
        card_search name, type: :wikirate_company
      end

      def ok_card_of_type type_code, **mark
        card = ok_card(**mark)
        card if card.type_code == type_code
      end

      def ok_card type_code, name: nil, id: nil
        card = ::Card.cardish(name || id)
        card if card&.ok?(:read) && (!type_code || card.type_code == type_code)
      end

      def card_search name, cql={}
        cql.merge! limit: 10
        cql[:name] = [:match, name] if name
        ::Card.search cql
      end
    end
  end
end
