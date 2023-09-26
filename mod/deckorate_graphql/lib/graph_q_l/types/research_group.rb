module GraphQL
  module Types
    # ResearchGroup type for GraphQL
    class ResearchGroup < WikirateCard
      cardtype_field :metric, Metric, nil, true
    end
  end
end
