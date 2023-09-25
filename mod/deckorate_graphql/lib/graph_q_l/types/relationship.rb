module GraphQL
  module Types
    # Relationship type for GraphQL
    class Relationship < WikirateCard
      field :year, Integer, null: false
      field :subject_company, Company, null: false
      field :object_company, Company, null: false
      field :metric, Metric, null: false
      field :inverse_metric, Metric, null: false

      field :value, String, null: false
      field :sources, [Source], null: false

      def id
        object.relationship_id
      end

      def subject_company
        object.subject_company_id.card
      end

      def object_company
        object.object_company_id.card
      end

      def metric
        object.metric_id.card.lookup
      end

      def inverse_metric
        object.inverse_metric_id.card.lookup
      end

      def sources
        object.source_card.item_cards
      end

      # value(unit: String = undefined, currency: String = undefined): FlexibleValueType
      # input_answers: [Answer]
      # relationships: [Relationship!]
    end
  end
end
