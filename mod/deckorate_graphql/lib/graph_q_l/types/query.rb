module GraphQL
  module Types
    # Root Query for GraphQL
    class Query < BaseObject
      class << self
        def cardtype_field fieldname, type, codename = nil
          codename ||= fieldname
          plural_fieldname = fieldname.to_s.to_name.vary(:plural).to_sym

          singular_field fieldname, type
          plural_field plural_fieldname, codename, type

          define_method(fieldname) { |**mark| ok_card codename, **mark }
          define_method plural_fieldname do |limit: 10, offset: 0, **filter|
            card_search codename, limit, offset, filter
          end
        end

        def subcardtype_field fieldname, type, codename = nil
          codename ||= fieldname
          plural_fieldname = fieldname.to_s.to_name.vary(:plural).to_sym

          plural_field plural_fieldname, codename, type

          define_method plural_fieldname do |limit: 10, offset: 0, **filter|
            card_search codename, limit, offset, filter
          end
        end

        def singular_field fieldname, type
          field fieldname, type, null: true do
            argument :name, String, required: false
            argument :id, Integer, required: false
          end
        end

        def plural_field fieldname, codename, type
          field fieldname, [type], null: false do
            argument :limit, Integer, required: false
            argument :offset, Integer, required: false

            codename.card.format.filter_keys.each do |filter|
              if filter == :country
                argument filter, CountryFilterType, required: false
              elsif filter == :value_type
                argument filter, ValueFilterType, required: false
              elsif filter == :research_policy
                argument filter, ResearchPolicyFilterType, required: false
              elsif filter == :metric_type
                argument filter, MetricCategoryFilterType, required: false
              elsif filter == :company_category
                argument filter, CompanyCategoryFilterType, required: false
              elsif filter == :company_group
                argument filter, CompanyGroupFilterType, required: false
              elsif filter == :designer
                argument filter, MetricDesignerFilterType, required: false
              elsif filter == :wikirate_topic
                argument filter, TopicFilterType, required: false
              else
                argument filter, String, required: false
              end
            end
          end
        end

        def default_limit
          10
        end

        def default_offset
          0
        end

      end

      cardtype_field :research_group, ResearchGroup
      cardtype_field :company_group, CompanyGroup
      cardtype_field :company, Company, :wikirate_company
      cardtype_field :metric, Metric, :metric
      cardtype_field :answer, Answer, :metric_answer
      cardtype_field :relationship, Relationship, :relationship_answer
      cardtype_field :topic, Topic, :wikirate_topic
      cardtype_field :dataset, Dataset
      cardtype_field :source, Source

      def metric **mark
        ok_card(:metric, **mark)&.lookup
      end

      def metrics limit: Query.default_limit, offset: Query.default_offset, **filter
        ::Card::MetricQuery.new(filter, {}, limit: limit, offset: offset).lookup_relation.all
      end

      def answer **mark
        ok_card :metric_answer, **mark
      end

      def answers metric: nil, limit: Query.default_limit, offset: Query.default_offset, **filter
        filter[:metric_id] = metric.card_id if metric
        ::Card::AnswerQuery.new(filter, {}, limit: limit, offset: offset).lookup_relation.all
      end

      def relationship **mark
        ok_card :relationship_answer, **mark
      end

      def relationships limit: Query.default_limit, offset: Query.default_offset, **filter
        ::Relationship.limit(limit).offset(offset).all
      end
    end
  end
end
