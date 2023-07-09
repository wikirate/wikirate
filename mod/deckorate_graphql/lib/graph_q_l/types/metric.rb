module GraphQL
  module Types
    # Metric type for GraphQL
    class Metric < Card
      field :designer, Card, null: false
      field :title, String, null: true
      field :question, String, null: true
      field :metric_type, String, null: true
      field :about, String, null: true
      field :methodology, String, null: true
      field :research_policy, String, null: true
      field :unit, String, null: true
      field :range, String, null: true
      field :formula, String, null: true
      field :report_type, String, null: true
      subcardtype_field :answer, Answer, :metric_answer
      field :relationships, [Relationship], null: true
      field :topics, [Topic], null: false
      subcardtype_field :dataset, Dataset

      def id
        object.id
      end

      def title
        object.metric_title
      end

      def designer
        object.designer_id.card
      end

      def answers limit: Card.default_limit, offset: Card.default_offset, **filter
        filter[:metric_id] = object.card_id
        ::Card::AnswerQuery.new(filter, {}, limit: limit, offset: offset).lookup_relation.all
      end

      def relationships
        return unless object.relationship?

        ::Relationship.where(object.metric_lookup_field => object.id).limit(10).all
      end

      def formula
        object.try :formula
      end

      def topics
        object.wikirate_topic_card.item_cards
      end

      def datasets
        referers :dataset, :metric
      end

      #   metric_type: metricType
      #   value_options: [Category!]!
      #   value_type: valueType
      #   scores: [Metric]
      #   calculations:[Metric!]!
    end
  end
end
