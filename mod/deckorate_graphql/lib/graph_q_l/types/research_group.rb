module GraphQL
  module Types
    # ResearchGroup type for GraphQL
    class ResearchGroup < Card
      subcardtype_field :metric, Metric
      def metrics limit: Card.default_limit, offset: Card.default_offset, **filter
        filter[:research_group] = object.name
        ::Card::MetricQuery.new(filter, {}, limit: limit, offset: offset).lookup_relation.all
      end

    end
  end
end
