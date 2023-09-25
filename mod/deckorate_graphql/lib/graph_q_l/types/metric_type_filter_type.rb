module GraphQL
  module Types
    # Metric type FilterType to provide all available metric type options
    class MetricTypeFilterType < FilterType
      filter_option_values(:metric, "metric_type")
    end
  end
end