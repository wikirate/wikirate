module GraphQL
  module Types
    class QueryType < BaseObject
      # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
      # include Types::Relay::HasNodeField
      # include Types::Relay::HasNodesField

      # Add root-level fields here.
      # They will be entry points for queries on your schema.

      field :card, Card, null: true do
        argument :name, String, required: false
        argument :id, Integer, required: false
      end

      field :cards, [Card], null: false do
        argument :name, String, required: false
        argument :type, String, required: false
      end

      field :company, Company, null: true do
        argument :name, String, required: false
        argument :id, Integer, required: false
      end

      field :companies, [Company], null: false do
        argument :name, String, required: false
      end

      field :metrics, [Metric], null: false

      def card **mark
        ok_card nil, **mark
      end

      def cards name: nil, type: nil
        card_search name, type
      end

      def company **mark
        ok_card :wikirate_company, **mark
      end

      def companies name: nil
        card_search name, type
      end

      def metrics
        ::Metric.limit(10).all
      end

      def answers
        ::Answer.limit(10).all
      end

      private

      def ok_card_of_type type_code, **mark
        card = ok_card(**mark)
        card if card.type_code == type_code
      end

      def ok_card type_code, name: nil, id: nil
        card = ::Card.fetch name || id
        card if card&.ok?(:read) && (!type_code || card.type_code == type_code)
      end

      def card_search name, type
        cql = { limit: 10 }
        cql[:type] = type if type
        cql[:name] = [:match, name] if name
        ::Card.search cql
      end
    end
  end
end
