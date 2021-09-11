module GraphQL
  module Types
    class Metric < Card
      field :designer, Card, null: false
      field :question, String, null: true
      field :about, String, null: true
      field :methodology, String, null: true
      field :research_policy, String, null: true
      field :unit, String, null: true
      field :range, String, null: true
      field :formula, String, null: true
      field :report_type, String, null: true

      field :answers, [Answer], null: false

      def id
        object.metric_id
      end

      def designer
        object.designer_id.card
      end

      def answers
        ::Answer.where(metric_id: object.metric_id).limit(10).all
      end

      def formula
        object.try :formula
      end

      # type Metric implements WikiRateEntity{
      #   metric_type: metricType
      #   value_options: [Category!]!
      #   value_type: valueType
      #   topics: [Topic!]!
      #   formula: String
      #   scores: String
      #   answers: [Answer!]!
      #   relationships: [Relationship!]    answers: [BaseAnswer!]
      #   datasets: [Datase!]!
      #   calculations:[String!]!
      # }
    end
  end
end
