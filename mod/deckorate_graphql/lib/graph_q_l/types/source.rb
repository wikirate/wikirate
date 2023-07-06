module GraphQL
  module Types
    # Source type for GraphQL
    class Source < Card
      field :title, String, null: true
      field :description, String, null: true
      field :report_type, String, null: true
      field :years, [Integer], null: true

      field :original_url, String, null: true
      field :file_url, String, null: true
      subcardtype_field :metric, Metric
      subcardtype_field :answer, Answer, :metric_answer
      subcardtype_field :company, Company, :wikirate_company

      field :relationships, [Relationship], null: false

      def title
        object.card.wikirate_title
      end

      def description
        description = object.card.fetch("description")
        description.content if description.present?
      end

      def metrics limit: Card.default_limit, offset: Card.default_offset, **filter
        filter[:source] = object.name
        ::Card::MetricQuery.new(filter, {}, limit: limit, offset: offset).lookup_relation.all
      end

      def relationships
        referers(:relationship_answer, :source)&.map(&:lookup)
      end

      def answers metric_id: nil, limit: Card.default_limit, offset: Card.default_offset, **filter
        filter[:source] = object.name
        filter[:metric_id] = metric_id if metric_id
        ::Card::AnswerQuery.new(filter, {}, limit: limit, offset: offset).lookup_relation.all
      end

      def original_url
        object.link_url
      end
    end
  end
end
