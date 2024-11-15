module GraphQL
  module Types
    # Record type for GraphQL
    class Record < DeckorateCard
      field :year, Integer, null: false
      field :company, Company, null: false
      field :metric, Metric, null: false
      field :value, RecordValue, null: false
      field :comments, String, null: true
      field :sources, [Source], null: true

      def id
        object.record_id
      end

      def company
        object.company_id.card
      end

      def metric
        object.metric_id.card
      end

      def sources
        object.source_card.item_cards
      end
    end
  end
end
