module GraphQL
  module Types
    # Answer type for GraphQL
    class Answer < WikirateCard
      field :year, Integer, null: false
      field :company, Company, null: false
      field :metric, Metric, null: false
      field :value, AnswerValue, null: false
      field :comments, String, null: true
      cardtype_field :source, Source, :source, true

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

      def relationships
        return unless object.relationship?

        Relationship.where(object.answer_lookup_field => object.id).limit(10).all
      end

    end
  end
end
