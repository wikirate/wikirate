module GraphQL
  module Types
    class MetricTypeFilterType < FilterType
      filter_option_values(:metric, "metric_type")
    end
  end
end