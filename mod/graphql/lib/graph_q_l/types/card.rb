module GraphQL
  module Types
    class Card < BaseObject
      field :id, Integer, null: true,
            description: "unique numerical identifier"

      field :type, Card, null: false,
            description: "card type"

      field :name, String, null: false,
            description: "name that is unique across all cards"

      field :linkname, String, null: false,
            description: "url-friendly name variant"

      field :created_at, Types::ISO8601DateTime, null: true,
            description: "Date and Time when created"

      field :updated_at, Types::ISO8601DateTime, null: true,
            description: "Date and Time when last updated"

      field :creator, Card, null: true,
            description: "User who created"

      field :updater, Card, null: true,
            description: "User who last updated"

      field :left, Card, null: true,
            description: "left name"

      field :right, Card, null: true,
            description: "left name"

      field :content, String, null: true,
            description: "core view of card rendered in text format"

      def type
        object.type_id.card
      end

      def link_name
        object.name.url_key
      end

      def left
        object.left_id.card
      end

      def right
        object.right_id.card
      end

      def content
        object.format(:text).render_core
      end

      def creator
        object.creator_id.card
      end

      def updater
        object.updater_id.card
      end
    end
  end
end
