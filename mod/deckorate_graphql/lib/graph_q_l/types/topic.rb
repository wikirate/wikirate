module GraphQL
  module Types
    # Topic type for GraphQL
    class Topic < WikirateCard
      lookup_field :metric, Metric
      cardtype_field :dataset, Dataset
      field :description, String, null: true
    end
  end
end
