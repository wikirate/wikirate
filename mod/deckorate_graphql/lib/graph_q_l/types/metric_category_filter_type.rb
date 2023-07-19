module GraphQL
  module Types
    class MetricCategoryFilterType < FilterType
      filter_option_values(:metric, "metric_type")
    end
  end
end