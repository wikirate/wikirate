module GraphQL
  module Types
    # Answer type for GraphQL
    class Answer < Card
      field :year, Integer, null: false
      field :company, Company, null: false
      field :metric, Metric, null: false

      field :value, String, null: false
      field :comments, String, null: true
      subcardtype_field :source, Company, :source

      field :relationships, [Relationship], null: false

      def id
        object.answer_id
      end

      def company
        object.company_id.card
      end

      def metric
        object.metric_id.card.lookup
      end

      def sources
        object.source_card.item_cards
      end

      def relationships
        return unless object.relationship?

        Relationship.where(object.answer_lookup_field => object.id).limit(10).all
      end

      # value(unit: String = undefined, currency: String = undefined): FlexibleValueType
      # input_answers: [Answer]
    end
  end
end
