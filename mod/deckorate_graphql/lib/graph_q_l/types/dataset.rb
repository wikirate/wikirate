module GraphQL
  module Types
    # Data Set type for GraphQL
    class Dataset < Card

      field :years, [Integer], null: false
      field :description, String, null: false
      subcardtype_field :company, Company, :wikirate_company
      subcardtype_field :metric, Metric
      subcardtype_field :answer, Answer, :metric_answer

      def years
        object.year_card.item_names.map(&:to_i)
      end

      def metrics limit: Card.default_limit, offset: Card.default_offset, **filter
        filter[:dataset] = object.name
        ::Card::MetricQuery.new(filter, {}, limit: limit, offset: offset).lookup_relation.all
      end

      def answers metric_id: nil, limit: Card.default_limit, offset: Card.default_offset, **filter
        filter[:dataset] = object.name
        filter[:metric_id] = metric_id if metric_id
        ::Card::AnswerQuery.new(filter, {}, limit: limit, offset: offset).lookup_relation.all
      end
    end
  end
end
