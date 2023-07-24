module GraphQL
  module Types
    # ResearchGroup type for GraphQL
    class ResearchGroup < WikirateCard
      lookup_field :metric, Metric, nil, true
    end
  end
end
