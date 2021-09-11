module GraphQL
  module Types
    class Answer < Card
      field :year, Integer, null: false
      field :company, Company, null: false
      field :metric, Metric, null: false

      field :value, String, null: false
      field :comments, String, null: true

      field :sources, [Source], null: false

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
      
      # value(unit: String = undefined, currency: String = undefined): FlexibleValueType
      # input_answers: [Answer]
      # relationships: [Relationship!]
    end
  end
end
