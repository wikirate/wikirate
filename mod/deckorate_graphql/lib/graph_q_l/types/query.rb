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

        def default_limit
          10
        end

        # def lookup_field fieldname, type, filter_query_class
        #
        # end
      end

      cardtype_field :research_group, ResearchGroup
      cardtype_field :company_group, CompanyGroup
      cardtype_field :company, Company, :wikirate_company
      cardtype_field :topic, Topic, :wikirate_topic
      cardtype_field :dataset, Dataset
      cardtype_field :source, Source

      field :metric, Metric, null: true do
        argument :name, String, required: false
        argument :id, Integer, required: false
      end
      field :metrics, [Metric], null: false do
        argument :limit, Integer, required: false
      end

      field :answer, Answer, null: true do
        argument :id, Integer, required: false
      end
      field :answers, [Answer], null: false do
        argument :metric, String, required: false
        argument :limit, Integer, required: false
        # argument :sort_by, String, required: false
        ::Card::AnswerQuery.card_id_filters.each do |filter|
          argument filter, String, required: false
        end
      end

      field :relationship, Relationship, null: true do
        argument :id, Integer, required: false
        argument :limit, Integer, required: false
      end
      field :relationships, [Relationship], null: false

      def metric **mark
        ok_card(:metric, **mark)&.lookup
      end

      def metrics limit: Query.default_limit
        ::Metric.limit(limit).all
      end

      def answer **mark
        ok_card :metric_answer, **mark
      end

      def answers metric: nil, limit: Query.default_limit, **filter
        filter[:metric_id] = metric.card_id if metric
        ::Card::AnswerQuery.new(filter, {}, limit: limit).lookup_relation.all
      end

      def relationship **mark
        ok_card :relationship_answer, **mark
      end

      def relationships limit: Query.default_limit
        ::Relationship.limit(limit).all
      end
    end
  end
end
