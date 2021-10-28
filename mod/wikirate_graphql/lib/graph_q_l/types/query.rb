module GraphQL
  module Types
    # Root Query for GraphQL
    class Query < BaseObject
      class << self
        def cardtype_field fieldname, type, codename=nil
          codename ||= fieldname
          plural_fieldname = fieldname.to_s.to_name.vary(:plural).to_sym

          singular_field fieldname, type
          plural_field plural_fieldname, type

          define_method(fieldname) { |**mark| ok_card codename, **mark }
          define_method plural_fieldname do |name: nil, limit: 10, offset: 0|
            card_search name, codename, limit, offset
          end
        end

        def singular_field fieldname, type
          field fieldname, type, null: true do
            argument :name, String, required: false
            argument :id, Integer, required: false
          end
        end

        def plural_field fieldname, type
          field fieldname, [type], null: false do
            argument :id, Integer, required: false
            argument :limit, Integer, required: false
            argument :offset, Integer, required: false
          end
        end
      end

      cardtype_field :company_group, CompanyGroup
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
      field :answers, [Answer], null: false do
        argument :metric, String, required: false
      end

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

      def answers metric: nil
        query = {}
        query[:metric_id] = metric.card_id if metric
        ::Answer.where(query).limit(10).all
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
