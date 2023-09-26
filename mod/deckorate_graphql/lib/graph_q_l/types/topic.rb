module GraphQL
  module Types
    # Topic type for GraphQL
    class Topic < WikirateCard
      lookup_field :metric, Metric, nil, true
      cardtype_field :dataset, Dataset, nil, true
      # field :description, String, null: true
    end
  end
end
