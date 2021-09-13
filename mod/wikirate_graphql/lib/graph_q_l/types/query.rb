module GraphQL
  module Types
    # Root Query for GraphQL
    class Query < BaseObject
      def self.cardtype_field field, type, codename=nil
        field field, type, null: true do
          argument :name, String, required: false
          argument :id, Integer, required: false
        end

        plural = field.to_s.to_name.vary(:plural).to_sym
        field plural, [type], null: false do
          argument :id, Integer, required: false
        end

        codename ||= field
        define_method field do |**mark|
          ok_card codename, **mark
        end

        define_method plural do |name: nil|
          card_search name, codename
        end
      end

      cardtype_field :company, Company, :wikirate_company
      cardtype_field :topic, Topic, :wikirate_topic
      cardtype_field :dataset, Dataset
      cardtype_field :source, Source

      field :metric, Metric, null: true do
        argument :name, String, required: false
        argument :id, Integer, required: false
      end
      field :metrics, [Metric], null: false

      field :answer, Answer, null: true do
        argument :id, Integer, required: false
      end
      field :answers, [Answer], null: false

      field :relationship, Relationship, null: true do
        argument :id, Integer, required: false
      end
      field :relationships, [Relationship], null: false

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

      def relationship **mark
        ok_card :relationship_answer, **mark
      end

      def relationships
        ::Relationship.limit(10).all
      end
    end
  end
end
