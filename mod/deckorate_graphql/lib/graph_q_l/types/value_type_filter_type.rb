module GraphQL
  module Types
    # Value type FilterType to provide all available value type options
    class ValueTypeFilterType < FilterType
      filter_option_values(:metric, "value_type")
    end

  end
end
