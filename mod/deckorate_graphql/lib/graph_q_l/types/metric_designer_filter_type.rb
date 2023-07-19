module GraphQL
  module Types
    class MetricDesignerFilterType < FilterType
      filter_option_values(:metric, "designer")
    end
  end
end