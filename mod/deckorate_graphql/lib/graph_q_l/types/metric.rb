module GraphQL
  module Types
    # Metric type for GraphQL
    class Metric < DeckorateCard
      field :designer, Card, null: true
      field :title, String, null: true
      field :question, String, null: true
      field :metric_type, String, null: true
      field :value_type, String, null: true
      field :value_options, [String], null: true
      field :about, String, null: true
      field :methodology, String, null: true
      field :assessment, String, null: true
      field :unit, String, null: true
      field :range, String, null: true
      field :formula, String, null: true
      field :report_type, String, null: true
      lookup_field :answer, Answer, :answer, true
      field :topics, [Topic], null: false
      field :datasets, [Dataset], null: false

      def id
        object.id
      end

      def title
        object.metric_title
      end

      def designer
        object.designer_id.card
      end

      def formula
        object.try :formula
      end

      def topics
        object.topic_card.item_cards
      end

      def datasets
        referers :dataset, :metric
      end
    end
  end
end
