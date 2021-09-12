module GraphQL
  module Types
    class Query < BaseObject
      field :company, Company, null: true do
        argument :name, String, required: false
        argument :id, Integer, required: false
      end

      field :companies, [Company], null: false do
        argument :name, String, required: false
      end

      field :metric, Metric, null: true do
        argument :name, String, required: false
        argument :id, Integer, required: false
      end
      field :metrics, [Metric], null: false

      field :answer, Answer, null: true do
        argument :id, Integer, required: false
      end
      field :answers, [Answer], null: false

      def company **mark
        ok_card :wikirate_company, **mark
      end

      def companies name: nil
        card_search name, :wikirate_company
      end

      def metric **mark
        ok_card(:metric, **mark)&.lookup
      end

      def metrics
        ::Metric.limit(10).all
      end

      def answer **mark
        ok_card :metric_answer, **mark
      end

      def answers
        ::Answer.limit(10).all
      end
    end
  end
end
