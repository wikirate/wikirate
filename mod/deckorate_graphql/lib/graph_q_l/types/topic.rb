module GraphQL
  module Types
    # Topic type for GraphQL
    class Topic < DeckorateCard
      lookup_field :metric, Metric, nil, true
      cardtype_field :dataset, Dataset, nil, true
    end
  end
end
