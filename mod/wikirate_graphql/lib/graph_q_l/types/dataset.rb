module GraphQL
  module Types
    # Data Set type for GraphQL
    class Dataset < Card
      field :companies, [Company], null: false
      field :metrics, [Metric], null: false
      field :years, [Integer], null: false
      field :description, String, null: false
      field :answers, [Answer], null: false

      def companies
        object.wikirate_company_card.item_cards
      end

      def metrics
        object.metric_card.item_cards
      end

      def years
        object.year_card.item_names.map(&:to_i)
      end

      def answers
        ::Card::AnswerQuery.new(dataset: object.name).lookup_relation.limit(10).all
      end
    end
  end
end
