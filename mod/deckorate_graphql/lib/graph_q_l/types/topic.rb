module GraphQL
  module Types
    # Topic type for GraphQL
    class Topic < Card
      subcardtype_field :metric, Metric
      subcardtype_field :dataset, Dataset
      field :description, String, null: true

      def metrics limit: Card.default_limit, offset: Card.default_offset, **filter
        filter[:wikirate_topic] = object.name
        ::Card::MetricQuery.new(filter, {}, limit: limit, offset: offset).lookup_relation.all
      end
    end
  end
end
